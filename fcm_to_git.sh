#!/usr/bin/env bash
# Copy the commits of an FCM (SVN) branch onto a git branch, one git commit
# per SVN revision.
#
# The git branch must already start from the same code the FCM branch was
# created from (see docs/03-create-github-branch.md). For each revision, a
# private SVN working copy is updated to that revision and rsynced into the
# git clone, and the result is committed with the original SVN message,
# prefixed with the original revision, author and date.
#
# Re-running continues after the last revision already converted.
#
# Nothing is pushed: review the commits, then push yourself
# (docs/05-review-and-push.md).

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [-d] FCM_BRANCH GIT_CLONE

  FCM_BRANCH  URL of the FCM branch, or a working copy of it
  GIT_CLONE   git clone with the target branch checked out

Options:
  -d          dry run: list the revisions that would be converted
  -h          show this help
EOF
}

die() {
  echo "fcm_to_git: ERROR: $*" >&2
  exit 1
}

info() {
  echo "fcm_to_git: $*"
}

# Run git in the git clone.
in_clone() {
  git -C "$git_clone" "$@"
}

# First non-blank line of stdin. Reads all of stdin, so that the command
# writing to it never fails with "broken pipe" (which pipefail would catch).
first_line() {
  awk 'NF && !found {print; found=1}'
}

# Compare the code in folders $1 and $2, printing any differences. Ignores
# .svn and .git, and empty folders (SVN keeps them, git cannot). Symlinks are
# compared as links, not followed.
same_code() {
  local line path differ=0
  while IFS= read -r line; do
    if [[ $line =~ ^Only\ in\ (.*):\ (.*)$ ]]; then
      path=${BASH_REMATCH[1]}/${BASH_REMATCH[2]}
      if [[ -d $path && ! -L $path ]] \
         && [[ -z $(find "$path" ! -type d -print -quit) ]]; then
        continue
      fi
    fi
    echo "$line"
    differ=1
  done < <(diff -rq --no-dereference --exclude=.svn --exclude=.git \
             "$1" "$2" 2>&1)
  return $differ
}

# Never stop silently.
trap 'echo "fcm_to_git: ERROR: unexpected failure at line $LINENO -" \
           "please report this" >&2' ERR

dry_run=false
while getopts "dh" opt; do
  case $opt in
    d) dry_run=true ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
[[ $# -eq 2 ]] || { usage >&2; exit 1; }

fcm_branch=$1
[[ -d $2 ]] || die "the folder '$2' does not exist.
  The second argument must be your GitHub checkout,
  e.g. ~/fcm_to_git_work/github/ukca"
git_clone=$(cd "$2" && pwd)

# --- Check the tools ---------------------------------------------------------

for cmd in git svn rsync; do
  command -v "$cmd" >/dev/null \
    || die "'$cmd' is not installed or not on your PATH"
done
if [[ -z $(git config user.name) || -z $(git config user.email) ]]; then
  die "git does not know your name and email yet. Set them with:
  git config --global user.name \"Your Name\"
  git config --global user.email \"you@example.ac.uk\""
fi

# --- Check the git clone -----------------------------------------------------

in_clone rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "'$git_clone' is not a GitHub (git) checkout.
  The second argument must be your GitHub checkout,
  e.g. ~/fcm_to_git_work/github/ukca"

git_branch=$(in_clone symbolic-ref --short -q HEAD) \
  || die "'$git_clone' is not on a branch. Switch to the branch you made
  in step 3 first:  git switch <branch name>"

[[ $git_branch != main && $git_branch != master ]] \
  || die "'$git_clone' is on '$git_branch'. Switch to the branch you made
  in step 3 first:  git switch <branch name>"

if [[ -n $(in_clone status --porcelain) ]]; then
  in_clone status --short | sed -n '1,10s/^/  /p' >&2
  die "'$git_clone' has changes that are not committed (listed above).
  If they are left over from an earlier run of this script, remove them with:
  cd $git_clone && git reset --hard && git clean -fd"
fi

# --- Find the SVN revisions --------------------------------------------------

if [[ -d $fcm_branch ]]; then
  svn_url=$(svn info --show-item url "$fcm_branch") \
    || die "'$fcm_branch' is not an FCM checkout"
else
  svn_url=${fcm_branch%/}
fi

# Check svn can log in to MOSRS and find the branch, before doing anything.
if ! svn_err=$(svn info --non-interactive "$svn_url" 2>&1 >/dev/null); then
  echo "$svn_err" | sed 's/^/  /' >&2
  if grep -q -e E215004 -e 'Authentication failed' <<<"$svn_err"; then
    die "svn could not log in to MOSRS. Run this, enter your MOSRS password,
  then run this script again:
  mosrs-cache-password"
  fi
  die "could not find the FCM branch $svn_url
  Check the address against 'fcm info' in your FCM checkout (step 1)."
fi

# Every revision on the branch, oldest first. The first one created the branch
# (the copy it was made from), so it is the starting point rather than a
# change.
# mapfile stores each revision in a bash array
mapfile -t revs < <(svn log -q --stop-on-copy -r 1:HEAD "$svn_url" \
                      | sed -n 's/^r\([0-9]\+\) |.*/\1/p')
# error if no revisions
[[ ${#revs[@]} -gt 0 ]] || die "could not read the history of $svn_url
  Check the branch URL is right and that svn can log in to MOSRS:
  svn info $svn_url"
# first revision = the one that created the branch
create_rev=${revs[0]}

# --- Find where the branch was made from -------------------------------------

repo_root=$(svn info --show-item repos-root-url "$svn_url")
branch_path=${svn_url#"$repo_root"}

# Print "PATH REV" that the repository path $1 (as it was at revision $2) was
# copied from when it was created.
copied_from() {
  local url=$repo_root$1@$2 first
  # get the revision from the path
  first=$(svn log -q --stop-on-copy -r 1:"$2" -l 1 "$url" \
            | sed -n 's/^r\([0-9]\+\) |.*/\1/p')
  # get the source of that revision
  svn log -v -q -r "$first" "$url" \
    | sed -n "s|^   [AR] $1 (from \(.*\):\([0-9]\+\))$|\1 \2|p"
}

# Follow the copies back to trunk. Usually this is one step (branch made from
# trunk); more steps mean the branch was made from another branch.
chain=()
from=$(copied_from "$branch_path" "$create_rev")
# keep going back until we find a trunk revision
while [[ -n $from ]]; do
  chain+=("${from% *}@${from##* }")
  [[ ${from% *} == */trunk ]] && break
  from=$(copied_from "${from% *}" "${from##* }")
done
[[ ${chain[-1]:-} == */trunk@* ]] \
  || die "could not work out which trunk revision $svn_url was made from"
trunk_rev=${chain[-1]##*@}
from_branch=false
# if greater than one chain, it was a branch of a branch
[[ ${#chain[@]} -gt 1 ]] && from_branch=true

# For a branch made from another branch, git has nothing matching the code it
# started from. Start the git branch from the nearest release tag instead; the
# first commit then brings the code up to where the FCM branch was made.
if $from_branch; then
  in_clone rev-parse -q --verify git_migration >/dev/null \
    || die "your GitHub clone does not have the release tags. Run:
  cd $git_clone && git fetch upstream --tags"

  # Last trunk commit at or before trunk_rev (see step 3.1 of the guide) ...
  trunk_commit=$(
    in_clone log --format='commit %H%n%b' git_migration \
      | awk -v rev="$trunk_rev" '
          /^commit / { h = $2 }
          /git-svn-id:/ && !found {
            split($2, a, "@")
            if (a[2] + 0 <= rev) { print h; found = 1 }
          }')

  # ... and the nearest release tag at or before that. Releases are tagged
  # vnX.Y (UM, LFRic Apps) or umX.Y (UKCA); other tags are not releases.
  # LFRic Apps has both on some commits, so vn comes first.
  start_tag=$(
    in_clone describe --tags --abbrev=0 --match 'vn[0-9]*' \
      "$trunk_commit" 2>/dev/null \
    || in_clone describe --tags --abbrev=0 --match 'um[0-9]*' \
      "$trunk_commit" 2>/dev/null) \
    || die "could not find a release tag (vn... or um...) before
  trunk r$trunk_rev"

fi

# --- Work out what is left to do ---------------------------------------------

# Continue from the last revision already converted onto this git branch.
last_rev=$(in_clone log -1 -F --grep="FCM-URL: $svn_url" --format=%B \
             | sed -n 's/^FCM-Revision: //p')
base_rev=${last_rev:-$create_rev}

todo=()
for rev in "${revs[@]:1}"; do
  [[ $rev -gt $base_rev ]] && todo+=("$rev")
done

# A branch made from another branch needs one extra commit first.
start_commit=false
[[ -z $last_rev ]] && $from_branch && start_commit=true
start_subject="Code from ${chain[0]}"

# Read the SVN details of revision $1 into svn_log, svn_author, svn_date,
# subject and body. subject is the git subject line: the original revision,
# author and date, then the first line of the SVN message (or $2 if given).
read_rev() {
  local rev=$1 short_date
  svn_log=$(svn propget --revprop -r "$rev" svn:log "$svn_url")
  svn_author=$(svn propget --revprop -r "$rev" svn:author "$svn_url")
  svn_date=$(svn propget --revprop -r "$rev" svn:date "$svn_url")
  svn_date=${svn_date%.*}Z    # drop the microseconds
  # "2025-02-18T09:11:54Z" -> "2025-02-18 09:11" for the subject line
  short_date="${svn_date:0:10} ${svn_date:11:5}"
  if [[ -n ${2:-} ]]; then
    subject=$2
    body=$svn_log
  else
    subject=$(first_line <<<"$svn_log")
    body=$(sed '0,/\S/d' <<<"$svn_log" | sed '/./,$!d')
  fi
  subject="fcm_to_git [r$rev $svn_author $short_date]: ${subject:-(none)}"
}

info "FCM branch:  $svn_url"
info "git branch:  $git_branch ($git_clone)"
info "created at:  r$create_rev, from ${chain[0]}"
if [[ -n $last_rev ]]; then
  info "resuming:    r$last_rev already converted"
fi
if $start_commit; then
  info "to convert:  ${#todo[@]} of $((${#revs[@]} - 1)) revisions," \
       "plus 1 commit for the code the branch was made from"
else
  info "to convert:  ${#todo[@]} of $((${#revs[@]} - 1)) revisions"
fi

if $from_branch; then
  {
    echo
    echo "fcm_to_git: WARNING: this FCM branch was not made from trunk," \
         "but from another"
    echo "  branch. It was made from"
    for link in "${chain[@]}"; do
      echo "    $link"
      [[ $link == "${chain[-1]}" ]] || echo "  which was made from"
    done
    echo "  The git branch must start from the nearest release:" \
         " START=$start_tag"
    echo "  Its first commit then sets the code to ${chain[0]}."
    echo "  That commit holds all the changes made on ${chain[0]%@*}"
    echo "  - not only yours - and they will show up in a pull request."
    echo
  } >&2
fi

if $dry_run; then
  if $start_commit; then
    read_rev "$create_rev" "$start_subject"
    echo "  $subject"
  fi
  for rev in "${todo[@]}"; do
    read_rev "$rev"
    echo "  $subject"
  done
  exit 0
fi
$start_commit || [[ ${#todo[@]} -gt 0 ]] || { info "nothing to do"; exit 0; }

# --- Check the starting point ------------------------------------------------

work=$(mktemp -d -t fcm_to_git.XXXXXX)
trap 'rm -rf "$work"' EXIT
wc=$work/wc

if $start_commit; then
  # The git branch must start from the recommended tag, so that the first
  # commit holds only the changes from trunk to where the branch was made.
  [[ $(in_clone rev-parse HEAD) \
       == $(in_clone rev-parse "$start_tag^{commit}") ]] \
    || die "the git branch '$git_branch' does not start from $start_tag
  (see the WARNING above). Nothing was changed. Set START=$start_tag in your
  details file, then delete the git branch and redo step 3."
fi

info "checking out r$base_rev ..."
svn checkout -q "$svn_url@$base_rev" "$wc"

# The git branch must hold exactly the code of the FCM branch at base_rev,
# otherwise the first commit would also contain unrelated differences.
if ! $start_commit \
   && ! same_code "$wc" "$git_clone" >"$work/diff"; then
  sed -n '1,20s/^/  /p' "$work/diff" >&2
  die "the git branch '$git_branch' does not start from the same code as
  the FCM branch (r$base_rev). Differences are listed above. Nothing was
  changed. The git branch was probably made from the wrong tag - redo step 3."
fi

# --- Convert each revision ---------------------------------------------------

# If anything fails part way, say how to tidy up and carry on.
trap 'echo "fcm_to_git: stopped while copying r$rev." \
           "To carry on, tidy up and run again:
  cd $git_clone && git reset --hard && git clean -fd
  If svn could not log in to MOSRS, run mosrs-cache-password first." >&2' ERR

# Copy the checkout in $wc into the git clone, and commit it as revision $1,
# with the subject $2 (default: first line of the SVN message) and the extra
# message text $3 (optional).
commit_rev() {
  local rev=$1 extra=${3:-}

  rsync -a --delete --exclude=.git --exclude=.svn "$wc/" "$git_clone/"
  in_clone add -A

  read_rev "$rev" "${2:-}"
  {
    echo "$subject"
    echo
    if [[ -n $extra ]]; then
      echo "$extra"
      echo
    fi
    if [[ -n $body ]]; then
      echo "$body"
      echo
    fi
    echo "FCM-URL: $svn_url"
    echo "FCM-Revision: $rev"
    echo "FCM-Author: $svn_author"
    echo "FCM-Date: $svn_date"
  } >"$work/msg"

  # --allow-empty keeps revisions that only changed SVN properties (e.g.
  # svn:mergeinfo), so every revision has a commit and resuming stays simple.
  # The commit is dated now; the original FCM date is in the message.
  in_clone commit -q --allow-empty --cleanup=verbatim -F "$work/msg"
}

if $start_commit; then
  rev=$create_rev
  commit_rev "$rev" "$start_subject" "$(
    echo "This FCM branch was not made from trunk, but from another branch."
    echo "It was made from"
    for link in "${chain[@]}"; do
      echo "  $link"
      [[ $link == "${chain[-1]}" ]] || echo "which was made from"
    done
    echo
    echo "This commit sets the code to where the FCM branch was made:"
    echo "  ${chain[0]}"
    echo "It holds all the changes from $start_tag up to that point,"
    echo "including those made on ${chain[0]%@*}."
    echo
    echo "Original FCM message:")"
  info "[start] $(in_clone log -1 --format='%h %s')"
fi

n=0
for rev in "${todo[@]}"; do
  n=$((n + 1))
  svn update -q -r "$rev" "$wc"
  commit_rev "$rev"
  info "[$n/${#todo[@]}] $(in_clone log -1 --format='%h %s')"
done
last_done=${todo[-1]:-$create_rev}

# --- Final check -------------------------------------------------------------

if ! same_code "$wc" "$git_clone" >"$work/diff"; then
  sed -n '1,20s/^/  /p' "$work/diff" >&2
  die "the git branch does not match the FCM branch at r$last_done
  (differences listed above). Do not push it - please report this."
fi

info "done - '$git_branch' matches the FCM branch at r$last_done"
info "nothing has been pushed - review the commits" \
     "(docs/05-review-and-push.md)"
