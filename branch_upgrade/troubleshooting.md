# Troubleshooting

Problems are listed by step. To find yours, search this page (`Ctrl+F`) for
part of the error message you see.

If you are stuck, ask - and include the command you ran and everything it
printed.

- [Any step](#any-step)
- [Step 0 - Before you start](#step-0---before-you-start)
- [Step 1 - Find your FCM branch](#step-1---find-your-fcm-branch)
- [Step 2 - Fork and tags](#step-2---fork-and-tags)
- [Step 3 - Create the GitHub branch](#step-3---create-the-github-branch)
- [Step 4 - Run fcm_to_git.sh](#step-4---run-fcm_to_gitsh)
- [Step 5 - Review and push](#step-5---review-and-push)
- [Step 6 - Merge a release](#step-6---merge-a-release)

## Any step

### The terminal shows `:` or `(END)` and won't take commands

You are in a viewer that git uses for long output. Scroll with the arrow keys;
press `q` to get out.

### A command seems stuck

It may be waiting for your MOSRS password or for `yes`/`no` - look at the last
line. Otherwise press `Ctrl+C` to stop it.

### `CHANGE_ME` appears in an error, or a value is empty

Your details file is not filled in, or not loaded in this terminal. Check it:

```bash
source ~/fcm_to_git_work/my_branch.sh
echo "$GH_USER"
echo "$FCM_URL"
echo "$START"
echo "$BRANCH"
```

Each should print a real value. If one prints `CHANGE_ME` or nothing, edit
`~/fcm_to_git_work/my_branch.sh` (see
[step 0](00-before-you-start.md#your-details-file)), save it and run the
`source` line again. Make sure there are no spaces around the `=` signs.

### `No such file or directory: /home/.../fcm_to_git_work/my_branch.sh`

The details file has not been made yet - see
[step 0](00-before-you-start.md#set-up-your-folders).

### `cd: ... No such file or directory`

That folder does not exist yet. Usually an earlier step was skipped. Check
which folders you have with `ls ~/fcm_to_git_work ~/fcm_to_git_work/*`.

## Step 0 - Before you start

### `command not found` for `fcm`, `svn`, `git` or `rsync`

The program is not installed or not set up in this terminal. On many HPC
machines you need to load it first, e.g. `module load git` - check your
machine's documentation, or ask its support team.

### `git version` is older than 2.23

Older git has no `git switch`. Either load a newer one (e.g.
`module avail git`), or use these instead throughout the guide:

| Instead of                  | use                           |
|-----------------------------|-------------------------------|
| `git switch -c NAME START`  | `git checkout -b NAME START`  |
| `git switch NAME`           | `git checkout NAME`           |

### `git: 'switch' is not a git command`

Same as above - your git is older than 2.23.

### `Authentication failed` / `No more credentials` / `svn could not log in to MOSRS` / asked for a MOSRS password

`fcm` and `svn` cannot log in to MOSRS. Run:

```bash
mosrs-cache-password
```

enter your MOSRS password, then try again. You need to do this **each time you
log in** to the machine. If it still fails, check you can log in to MOSRS in a
web browser - your password may have expired.

### `ssh -T git@github.com` says `Permission denied (publickey)`

GitHub does not recognise this machine. You need an SSH key on this machine,
added to your GitHub account - follow
[Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).
Then run `ssh -T git@github.com` again.

### `ssh -T git@github.com` hangs, or says `Connection timed out`

SSH to GitHub is blocked on this machine - e.g. on **Monsoon**, where it is
not available at all. Press `Ctrl+C` to stop a hanging command. This guide
needs SSH, so either do the migration on another machine where both `fcm` and
SSH to GitHub work, or use HTTPS with a token - see
[If SSH to GitHub does not work](00-before-you-start.md#if-ssh-to-github-does-not-work-eg-monsoon).

### `ssh -T git@github.com` says `Are you sure you want to continue connecting (yes/no)?`

Normal the first time. Type `yes` and press Enter.

### `git config user.name` prints nothing

Set your name and email - see
[step 0](00-before-you-start.md#check-your-machine-is-ready).

## Step 1 - Find your FCM branch

### `URL ... doesn't exist` or `path not found`

The branch address is wrong. List your branches to get the name exactly
(replace `robertwaters` with your MOSRS username):

```bash
source ~/fcm_to_git_work/my_branch.sh
fcm ls "fcm:$REPO_NAME.x_br/dev/robertwaters"
```

### `fcm status` lists files

These are changes on your computer that are **not** on MOSRS, so they will not
be converted. The letter at the start of each line says what kind:

| Letter | Meaning                         | What to do |
|--------|---------------------------------|------------|
| `M`    | File changed but not committed  | If you want to keep the change, commit it: `fcm commit`. If not: `fcm revert <file>` |
| `?`    | New file that FCM doesn't know  | If it belongs on the branch: `fcm add <file>` then `fcm commit`. If not (e.g. output, notes), ignore it |
| `A`    | File added but not committed    | `fcm commit` |
| `D`    | File deleted but not committed  | `fcm commit` |
| `C`    | Conflict                        | Sort out the conflict first, as you would in FCM |

Then run `fcm status` again.

### `fcm keyword-print fcm:ukca` says `location keyword not defined`

Use `fcm:ukca.x` (with `.x`), not `fcm:ukca`.

### `fcm branch-info` says `not a working copy` or `not a valid branch`

Give it your branch address - load your details file first:

```bash
source ~/fcm_to_git_work/my_branch.sh
fcm branch-info "$FCM_URL"
```

### There is no `Branch Parent` line

Make sure `FCM_URL` is a branch (the address has `branches/dev/...` in it),
not trunk.

### My branch name starts with a release, but `Branch Parent` is a different one

Trust `Branch Parent` - branch names are only a convention.

## Step 2 - Fork and tags

### `fatal: 'upstream' does not appear to be a git repository`

Your clone is not linked to the official MetOffice repository - step 2.4 was
not done in this clone (e.g. you cloned it again later). Any command with
`upstream` in it fails until you add the link:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git remote add upstream "git@github.com:MetOffice/$REPO_NAME.git"
git remote -v
```

`git remote -v` should then show `upstream` as well as `origin` - see
[2.4](02-fork-and-tags.md#24-link-your-clone-to-the-official-repository).
Then run the command that failed again.

### GitHub says I already have a fork

Fine - GitHub takes you to your existing fork. Carry on from 2.2, and make
sure Actions are off and the tags are copied (2.5).

### I'm getting emails about failed GitHub Actions / workflow runs

Actions are still on for your fork - see
[2.2](02-fork-and-tags.md#22-turn-off-github-actions-on-your-fork).

### `git clone` says `Permission denied (publickey)`

See [the SSH problem above](#ssh--t-gitgithubcom-says-permission-denied-publickey).

### `git clone` says `Repository not found`

Check your fork exists in the browser at
`https://github.com/<your username>/ukca`, and that `GH_USER` in your details
file is exactly your GitHub username (`echo "$GH_USER"`).

### `git clone` says `destination path 'ukca' already exists`

You already have a clone there. Use it: run
`source ~/fcm_to_git_work/my_branch.sh` then `cd "$GH_CLONE"`.
Check it is your fork with `git remote -v` - `origin` should show your
username.

### `git remote add` says `remote upstream already exists`

Fine - it was added before. Check it with `git remote -v`: `upstream` should
be `git@github.com:MetOffice/ukca.git`. If it is something else:

```bash
source ~/fcm_to_git_work/my_branch.sh
git remote set-url upstream "git@github.com:MetOffice/$REPO_NAME.git"
```

### `git push origin --tags` says `! [rejected] ... (already exists)`

Your fork already has a tag with that name, but pointing at different code.
This is unusual - ask for help before going on, especially if it is the tag
you need.

### My release tag is not on my fork

Make sure you ran both commands in 2.5, in your GitHub clone. Then check the
tag exists in MetOffice's repository:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git ls-remote --tags upstream "$START"
```

If this prints nothing too, the release name is wrong - check it against
`fcm keyword-print fcm:ukca.x` (step 1).

## Step 3 - Create the GitHub branch

### `fatal: invalid reference: um13.7` (or another release)

Your clone does not have that tag. Download the tags and try again:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git fetch upstream --tags
```

If you see `invalid reference: CHANGE_ME`, `START` is not filled in - see
[above](#change_me-appears-in-an-error-or-a-value-is-empty).

If it still fails after fetching the tags, that release has no tag on GitHub.
A few FCM releases were not given one - e.g. `vn13.8.1` (UM) and `vn2.2.1`
(LFRic Apps). Find its trunk revision with `fcm keyword-print`, e.g.

```bash
fcm keyword-print fcm:lfric_apps.x | grep vn2.2.1
```

```
revision[lfric_apps.x:vn2.2.1] = 13227
```

and treat your branch as if its name started with `r` and that number
(`r13227`) - see
[step 3.1](03-create-github-branch.md#31-only-if-your-branch-name-starts-with-r-find-the-starting-commit).

### `fatal: '' is not a valid branch name` or `fatal: missing branch name`

Your details file is not loaded in this terminal - run
`source ~/fcm_to_git_work/my_branch.sh` and try again.

### `fatal: a branch named '...' already exists`

You made this branch before. If you have **not** run step 4 yet, or want to
start again, delete it and redo step 3:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git switch main
git branch -D "$BRANCH"
```

If you have run step 4 and just want to carry on, switch to it instead:
`git switch "$BRANCH"`.

### `fatal: not a git repository`

You are not in your GitHub clone. Run `source ~/fcm_to_git_work/my_branch.sh`
then `cd "$GH_CLONE"` first.

### Step 3.1 prints nothing

Check `REV` is just the number (e.g. `REV=5137`, no `r`), and that you have
the tags (`git fetch upstream --tags`).

## Step 4 - Run fcm_to_git.sh

The script's error messages start with `fcm_to_git: ERROR:`. Nothing has been
pushed to GitHub, whatever the error.

### `No such file or directory` for `fcm_to_git.sh`

The script is not where your details file says. Check you cloned it in step 0:
`ls ~/fcm_to_git_work/fcm_to_git/fcm_to_git.sh`.

### `Permission denied` for `fcm_to_git.sh`

Make it runnable, then try again:

```bash
chmod +x ~/fcm_to_git_work/fcm_to_git/fcm_to_git.sh
```

### `ERROR: git does not know your name and email yet`

Run the two `git config --global` commands the message shows, with your own
name and email, then run the script again.

### `ERROR: the folder '...' does not exist` / `is not a GitHub (git) checkout`

The second thing after the script name must be your GitHub clone. Check
`echo "$GH_CLONE"` prints `.../fcm_to_git_work/github/ukca`, and that folder
exists (step 2.3).

### `ERROR: '...' is on 'main'` (or `'master'`) / `is not on a branch`

Your GitHub clone is not on the branch from step 3. Switch to it:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git switch "$BRANCH"
```

If that says the branch does not exist, do step 3.

### `ERROR: ... has changes that are not committed`

Something in your GitHub clone has changed that git hasn't saved. The script
lists the files above the error.

- **If you ran the script before and it stopped part way** - these are left
  over from that run. Remove them and run the script again:

  ```bash
  source ~/fcm_to_git_work/my_branch.sh
  cd "$GH_CLONE"
  git reset --hard
  git clean -fd
  ```

- **If you edited files in the clone yourself** - the commands above would
  delete those edits. Copy anything you want to keep somewhere else first.

### `ERROR: the git branch '...' does not start from the same code as the FCM branch`

The git branch was started from the wrong place, so the script stopped
without changing anything. The lines above the error list the files that
differ. Usually:

- `START` is wrong - recheck it with `fcm branch-info`, as in
  [step 1.4](01-find-fcm-branch.md#if-your-branch-name-starts-with-neither)
  (the branch name may not match where the branch really started); or
- the branch was made from `main` rather than from `START`; or
- your branch was made from someone else's branch - the script then prints a
  `WARNING` first; see
  [step 4](04-convert-commits.md#if-your-branch-was-made-from-another-branch).

Fix `START` in your details file, then delete the branch and redo step 3:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git switch main
git branch -D "$BRANCH"
```

### `ERROR: could not read the history of ...`

`svn` could not read your FCM branch. Either the address is wrong - check
`FCM_URL` in your details file against `fcm info` (step 1.3) - or `svn` could
not log in to MOSRS - see
[the password problem above](#authentication-failed--no-more-credentials--svn-could-not-log-in-to-mosrs--asked-for-a-mosrs-password).

### `ERROR: svn could not log in to MOSRS`

Run `mosrs-cache-password`, enter your MOSRS password, and run the script
again.

### `WARNING: this FCM branch was not made from trunk, but from another branch`

Your branch was made from someone else's branch. The script can still convert
it - see
[step 4: If your branch was made from another branch](04-convert-commits.md#if-your-branch-was-made-from-another-branch).

### `ERROR: the git branch '...' does not start from um13.8 (see the WARNING above)`

Your branch was made from another branch, and your git branch must start from
the release the warning names (here `um13.8`). Nothing was changed. Set
`START` to that release in your details file, then delete the git branch and
redo step 3 - see
[step 4](04-convert-commits.md#if-your-branch-was-made-from-another-branch).

### `ERROR: unexpected failure at line ...`

Something went wrong that the script did not expect. Ask for help, and
include everything the script printed.

### `ERROR: could not find the FCM branch ...`

`svn` logged in, but there is no branch at that address. Check `FCM_URL` in
your details file against the `URL:` line of `fcm info` (step 1.3).

### It keeps asking for my MOSRS password

Press `Ctrl+C`, run `mosrs-cache-password`, then run the script again - it
carries on from where it stopped (tidy up first if it tells you to).

### `stopped while copying r....`

Something went wrong part way, usually the connection to MOSRS. The commits
copied so far are kept. Tidy up, make sure you are logged in to MOSRS, then
run the script again - it carries on from where it stopped:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git reset --hard
git clean -fd
mosrs-cache-password
```

### `fcm_to_git: nothing to do`

Every FCM commit has already been copied. Go on to step 5.

### `to convert: 0` in the dry run, but the branch has commits

Check `FCM_URL` is your branch, not trunk or someone else's branch.

### `ERROR: the git branch does not match the FCM branch at r...`

The copy finished, but the final check found a difference. **Do not push.**
Ask for help, and include everything the script printed.

## Step 5 - Review and push

### The number of commits is not the same as **to convert**

If you ran the script more than once, add up the **to convert** numbers - or
run the dry run again: it should now say `to convert: 0 of N`, and N should
match. If it still does not match, ask before pushing.

### `fatal: ambiguous argument 'um13.7..um13.7_...'`

The details file is not loaded, or `START` or `BRANCH` is wrong - see
[above](#change_me-appears-in-an-error-or-a-value-is-empty).

### `git push` says `Permission denied (publickey)`

See [the SSH problem above](#ssh--t-gitgithubcom-says-permission-denied-publickey).

### `git push` says `Permission to MetOffice/ukca.git denied`

You are pushing to MetOffice, not your fork. Use `origin`:
`git push -u origin "$BRANCH"`. Check `git remote -v`: `origin` must show your
username.

### `git push` says `! [rejected] ... (fetch first)` or `(non-fast-forward)`

There is already a branch with this name on your fork, with different
commits - usually an earlier attempt. If you are sure the copy on GitHub is an
old attempt you do not want, replace it:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git push --force-with-lease -u origin "$BRANCH"
```

If you are not sure, ask first - this replaces what is on GitHub.

### I pushed and want to start again

The branch is only on your fork, so this affects nobody else. Delete it from
your fork and from your computer, then redo steps 3 to 5:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git push origin --delete "$BRANCH"
git switch main
git branch -D "$BRANCH"
```

### GitHub Actions ran when I pushed

Actions are still on for your fork - turn them off as in
[2.2](02-fork-and-tags.md#22-turn-off-github-actions-on-your-fork). The runs
do no harm; you can ignore them.

## Step 6 - Merge a release

### `merge: 2025.12.1 - not something we can merge`

Your clone does not have the tag. Download the tags and try again:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git fetch upstream --tags
```

If it says `merge: - not something we can merge` (no release name), your
details file has no `MERGE_TAG` line - see
[6.1](06-merge-first-release.md#61-make-a-copy-of-your-branch).

### `Already up to date.`

Your branch already includes that release - nothing to do.

### `Please commit your changes or stash them before you merge`

You have changed files in your clone since step 5. `git status` lists them.
If you do not need them, remove them with `git reset --hard`; otherwise copy
them somewhere safe first.

### `You have not concluded your merge (MERGE_HEAD exists)` / `you have unmerged files`

A merge is still in progress. Either finish it (fix the conflicts, `git add`
the files, then `git commit --no-edit --cleanup=strip` - see
[6.3](06-merge-first-release.md#63-fix-the-conflicts)) or cancel it with
`git merge --abort`.

### `git commit` opened an editor

You left out `--no-edit`. The message is already filled in - just save and
close: in `vi` type `:wq` and press Enter; in `nano` press `Ctrl+O`, Enter,
then `Ctrl+X`.

### After the merge commit, `git status` still shows a modified file

You changed the file again after marking it fixed (`git add`, or the **+** in
VS Code), so the merge commit has the earlier version. If you have not pushed
yet, add the change to the merge commit:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git add path/to/file
git commit --amend --no-edit
```

If you have already pushed, make it a normal commit instead
(`git commit -m "Finish merge of $MERGE_TAG"`) and push again.

### I made the merge commit, but got it wrong

The merge is on the copy (e.g. `2025.12.1_...`), so your migrated branch is
fine. Delete the copy and start step 6 again:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git switch "$BRANCH"
git branch -D "$MERGED_BRANCH"
```

If you had already pushed the copy, also delete it from your fork:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git push origin --delete "$MERGED_BRANCH"
```

### `fatal: a branch named '2025.12.1_...' already exists`

You made the copy before. To carry on with it, switch to it:
`git switch "$MERGED_BRANCH"`. To start again, delete it as in
[the entry above](#i-made-the-merge-commit-but-got-it-wrong) and redo 6.1.

### `fatal: '_...' is not a valid branch name`

`MERGED_BRANCH` is missing its release - your details file has no
`MERGE_TAG` line, or it comes after the `MERGED_BRANCH` line. See
[6.1](06-merge-first-release.md#61-make-a-copy-of-your-branch).

### There are too many conflicts to sort out

Cancel with `git merge --abort` - the copy is back as it was, and your
migrated branch was never touched. Step 6 is optional, so you can simply
stop here. If you do need the merge, talk to someone who knows the code you
changed: the conflicts are the same ones an `fcm merge` of trunk would give,
so they need the same care.

### The test suite still fails after the merge

Check `dependencies.yaml` (step
[6.4](06-merge-first-release.md#64-update-dependenciesyaml)): every `ref:`
should be a release such as `2025.12.1`, or your own branch. Old test suite
changes on your branch may also need redoing in the new `.cylc` files.
