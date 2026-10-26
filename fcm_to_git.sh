#!/usr/bin/env bash
# Copy the commits of an FCM (SVN) branch onto a git branch, one git commit
# per SVN revision.
#
# The git branch must already start from the same code the FCM branch was
# created from (see docs/03-create-github-branch.md). For each revision, a
# private SVN working copy is updated to that revision and rsynced into the
# git clone, and the result is committed with the original SVN message.
#
# Re-running continues after the last revision already converted.
#
# Nothing is pushed: review the commits, then push yourself
# (docs/05-review-and-push.md).

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [-n] FCM_BRANCH GIT_CLONE

  FCM_BRANCH  URL of the FCM branch, or a working copy of it
  GIT_CLONE   git clone with the target branch checked out

Options:
  -n          dry run: list the revisions that would be converted
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

dry_run=false
while getopts "nh" opt; do
  case $opt in
    n) dry_run=true ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
[[ $# -eq 2 ]] || { usage >&2; exit 1; }

fcm_branch=$1
git_clone=$(cd "$2" && pwd) || die "no such directory: $2"

# --- Check the git clone ------------------------------------------------------

git -C "$git_clone" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "$git_clone is not a git clone"
git_branch=$(git -C "$git_clone" symbolic-ref --short -q HEAD) \
  || die "$git_clone is not on a branch (detached HEAD)"
[[ -z $(git -C "$git_clone" status --porcelain) ]] \
  || die "$git_clone has uncommitted changes - commit or stash them first"

# --- Find the SVN revisions ---------------------------------------------------

if [[ -d $fcm_branch ]]; then
  svn_url=$(svn info --show-item url "$fcm_branch")
else
  svn_url=${fcm_branch%/}
fi

# Every revision on the branch, oldest first. The first one created the branch
# (the copy from trunk), so it is the starting point rather than a change.
mapfile -t revs < <(svn log -q --stop-on-copy -r 1:HEAD "$svn_url" \
                      | sed -n 's/^r\([0-9]\+\) |.*/\1/p')
[[ ${#revs[@]} -gt 0 ]] || die "no revisions found for $svn_url"
create_rev=${revs[0]}

# Continue from the last revision already converted onto this git branch.
last_rev=$(git -C "$git_clone" log -1 -F --grep="FCM-URL: $svn_url" \
             --format='%(trailers:key=FCM-Revision,valueonly,separator=)')
base_rev=${last_rev:-$create_rev}

todo=()
for rev in "${revs[@]:1}"; do
  [[ $rev -gt $base_rev ]] && todo+=("$rev")
done

info "FCM branch:  $svn_url"
info "git branch:  $git_branch ($git_clone)"
info "created at:  r$create_rev"
if [[ -n $last_rev ]]; then
  info "resuming:    r$last_rev already converted"
fi
info "to convert:  ${#todo[@]} of $((${#revs[@]} - 1)) revisions"

if $dry_run; then
  for rev in "${todo[@]}"; do
    subject=$(svn propget --revprop -r "$rev" svn:log "$svn_url" | sed '/^\s*$/d' | head -1)
    echo "  r$rev  $subject"
  done
  exit 0
fi
[[ ${#todo[@]} -gt 0 ]] || { info "nothing to do"; exit 0; }

# --- Check the starting point -------------------------------------------------

work=$(mktemp -d -t fcm_to_git.XXXXXX)
trap 'rm -rf "$work"' EXIT
wc=$work/wc

info "checking out r$base_rev ..."
svn checkout -q "$svn_url@$base_rev" "$wc"

# The git branch must hold exactly the code of the FCM branch at base_rev,
# otherwise the first commit would also contain unrelated differences.
if ! diff -rq --exclude=.svn --exclude=.git "$wc" "$git_clone" >"$work/diff"; then
  sed 's/^/  /' "$work/diff" | head -20 >&2
  die "git branch '$git_branch' does not match the FCM branch at r$base_rev.
  Create the git branch from the matching tag or commit
  (docs/03-create-github-branch.md) and run again."
fi

# --- Convert each revision ----------------------------------------------------

n=0
for rev in "${todo[@]}"; do
  n=$((n + 1))

  svn update -q -r "$rev" "$wc"
  rsync -a --delete --exclude=.git --exclude=.svn "$wc/" "$git_clone/"
  git -C "$git_clone" add -A

  svn_log=$(svn propget --revprop -r "$rev" svn:log "$svn_url")
  svn_author=$(svn propget --revprop -r "$rev" svn:author "$svn_url")
  svn_date=$(svn propget --revprop -r "$rev" svn:date "$svn_url")
  svn_date=${svn_date%.*}Z    # drop the microseconds

  # First non-blank line of the SVN message becomes the subject.
  subject=$(sed '/^\s*$/d' <<<"$svn_log" | head -1)
  body=$(sed '0,/\S/d' <<<"$svn_log" | sed '/./,$!d')

  {
    echo "fcm_to_git: ${subject:-(no message)}"
    echo
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
  GIT_AUTHOR_DATE=$svn_date git -C "$git_clone" commit -q --allow-empty \
    --cleanup=verbatim -F "$work/msg"

  info "[$n/${#todo[@]}] r$rev -> $(git -C "$git_clone" rev-parse --short HEAD)  $subject"
done

# --- Final check --------------------------------------------------------------

if ! diff -rq --exclude=.svn --exclude=.git "$wc" "$git_clone" >"$work/diff"; then
  sed 's/^/  /' "$work/diff" | head -20 >&2
  die "git branch does not match the FCM branch at r${todo[-1]}"
fi

info "done - '$git_branch' matches the FCM branch at r${todo[-1]}"
info "nothing has been pushed - review the commits (docs/05-review-and-push.md)"
