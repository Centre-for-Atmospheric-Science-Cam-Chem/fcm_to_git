# Troubleshooting

Problems are listed by step. To find yours, search this page (`Ctrl+F`) for
part of the error message you see.

If you are stuck, ask - and include the command you ran and everything it
printed.

- [Any step](#any-step)
- [Step 0 - Before you start](#step-0---before-you-start)
- [Step 1 - Merge the release](#step-1---merge-the-release)
- [Step 2 - Test your upgraded branch](#step-2---test-your-upgraded-branch)

## Any step

### The terminal shows `:` or `(END)` and won't take commands

You are in a viewer that git uses for long output. Scroll with the arrow keys;
press `q` to get out.

### A command seems stuck

It may be waiting for `yes`/`no` - look at the last line. Otherwise press
`Ctrl+C` to stop it.

### `CHANGE_ME` appears in an error, or a value is empty

Your details file is not filled in, or not loaded in this terminal. Check it:

```bash
source ~/branch_upgrade_work/my_branch.sh
echo "$GH_USER"
echo "$BRANCH"
echo "$TARGET_TAG"
echo "$GH_CLONE"
echo "$UPGRADED_BRANCH"
```

Each should print a real value. If one prints `CHANGE_ME` or nothing, edit
`~/branch_upgrade_work/my_branch.sh` (see
[step 0.2](00-before-you-start.md#02-fill-in-your-details-file)), save it and
run the `source` line again. Make sure there are no spaces around the `=`
signs.

### `No such file or directory: /home/.../branch_upgrade_work/my_branch.sh`

The details file has not been made yet - see
[step 0.1](00-before-you-start.md#01-set-up-your-folder).

### `cd: ... No such file or directory`

That folder does not exist yet. Usually an earlier step was skipped. If it is
your clone, check `GH_CLONE` in your details file
(`echo "$GH_CLONE"`) - see
[step 0.4](00-before-you-start.md#04-your-clone).

### `fatal: not a git repository`

You are not in your GitHub clone. Run
`source ~/branch_upgrade_work/my_branch.sh` then `cd "$GH_CLONE"`, and check
`GH_CLONE` is the folder of your clone.

## Step 0 - Before you start

### `command not found` for `git`

Git is not installed or not set up in this terminal. On many HPC machines you
need to load it first, e.g. `module load git` - check your machine's
documentation, or ask its support team.

### `git version` is older than 2.23

Older git has no `git switch`. Either load a newer one (e.g.
`module avail git`), or use these instead throughout the guide:

| Instead of                  | use                           |
|-----------------------------|-------------------------------|
| `git switch -c NAME`        | `git checkout -b NAME`        |
| `git switch NAME`           | `git checkout NAME`           |

### `git: 'switch' is not a git command`

Same as above - your git is older than 2.23.

### `ssh -T git@github.com` says `Permission denied (publickey)`

GitHub does not recognise this machine. You need an SSH key on this machine,
added to your GitHub account - follow
[Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).
Then run `ssh -T git@github.com` again.

### `ssh -T git@github.com` hangs, or says `Connection timed out`

SSH to GitHub is blocked on this machine - e.g. on **Monsoon**, where it is
not available at all. Press `Ctrl+C` to stop a hanging command. This guide
needs SSH, so either do the upgrade on another machine where SSH to GitHub
works, or use HTTPS with a token - see
[If SSH to GitHub does not work](00-before-you-start.md#if-ssh-to-github-does-not-work-eg-monsoon).

### `ssh -T git@github.com` says `Are you sure you want to continue connecting (yes/no)?`

Normal the first time. Type `yes` and press Enter.

### `git config user.name` prints nothing

Set your name and email - see
[step 0](00-before-you-start.md#check-your-machine-is-ready).

### `git clone` says `Permission denied (publickey)`

See [the SSH problem above](#ssh--t-gitgithubcom-says-permission-denied-publickey).

### `git clone` says `Repository not found`

Check your fork exists in the browser at
`https://github.com/<your username>/ukca`, and that `GH_USER` in your details
file is exactly your GitHub username (`echo "$GH_USER"`).

### `git clone` says `destination path 'ukca' already exists`

You already have a clone there. Use it: run
`source ~/branch_upgrade_work/my_branch.sh` then `cd "$GH_CLONE"`.
Check it is your fork with `git remote -v` - `origin` should show your
username.

### `fatal: 'upstream' does not appear to be a git repository`

Your clone is not linked to the official MetOffice repository. Any command
with `upstream` in it fails until you add the link - see
[step 0.5](00-before-you-start.md#05-link-your-clone-to-the-official-repository-and-get-the-tags).
Then run the command that failed again.

### `git remote add` says `remote upstream already exists`

Fine - it was added before. Check it with `git remote -v`: `upstream` should
be `git@github.com:MetOffice/ukca.git`. If it is something else:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git remote set-url upstream "git@github.com:MetOffice/$REPO_NAME.git"
```

### `git tag --list` prints nothing

The release is not in your clone. Check `TARGET_TAG` is spelt exactly as in
the [table of releases](../README.md#releases-and-tags) (`echo "$TARGET_TAG"`),
and that `git fetch upstream --tags` worked. You can see all the releases at
`https://github.com/MetOffice/ukca/tags`.

### `fatal: invalid reference` or `did not match any file(s) known to git` from `git switch`

Your branch is not in your clone. Check `BRANCH` is spelt exactly as on
GitHub (`echo "$BRANCH"`). If the branch is only on GitHub, download it:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git fetch origin
git switch "$BRANCH"
```

### `git status` lists changed files, or says ahead or behind

- **Changed files:** you have changed files that are not committed. If you
  need them, commit them to your branch first; if not, remove them with
  `git reset --hard`. If you are not sure, ask.
- **Ahead:** your clone has commits not yet on GitHub. Push them first:
  `git push`.
- **Behind:** GitHub has commits not yet in your clone (e.g. pushed from
  another machine). Get them first: `git pull`.

### I'm getting emails about failed GitHub Actions / workflow runs

Actions are still on for your fork - see
[step 0.3](00-before-you-start.md#03-your-fork-on-github).

## Step 1 - Merge the release

### `merge: 2025.12.1 - not something we can merge`

Your clone does not have the tag. Download the tags and try again:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git fetch upstream --tags
```

If it says `merge: - not something we can merge` (no release name), your
details file is not loaded, or has no `TARGET_TAG` line - see
[above](#change_me-appears-in-an-error-or-a-value-is-empty).

### `Already up to date.`

Your branch already includes that release - nothing to do.

### `Please commit your changes or stash them before you merge`

You have changed files in your clone. `git status` lists them. If you do not
need them, remove them with `git reset --hard`; otherwise copy them somewhere
safe first.

### `You have not concluded your merge (MERGE_HEAD exists)` / `you have unmerged files`

A merge is still in progress. Either finish it (fix the conflicts, `git add`
the files, then `git commit --no-edit --cleanup=strip` - see
[1.3](01-merge-release.md#13-fix-the-conflicts)) or cancel it with
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
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git add path/to/file
git commit --amend --no-edit
```

If you have already pushed, make it a normal commit instead
(`git commit -m "Finish merge of $TARGET_TAG"`) and push again.

### I made the merge commit, but got it wrong

The merge is on the copy (e.g. `2025.12.1_...`), so your original branch is
fine. Delete the copy and start step 1 again:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git switch "$BRANCH"
git branch -D "$UPGRADED_BRANCH"
```

If you had already pushed the copy, also delete it from your fork:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git push origin --delete "$UPGRADED_BRANCH"
```

### `fatal: a branch named '2025.12.1_...' already exists`

You made the copy before. To carry on with it, switch to it:
`git switch "$UPGRADED_BRANCH"`. To start again, delete it as in
[the entry above](#i-made-the-merge-commit-but-got-it-wrong) and redo 1.1.

If `UPGRADED_BRANCH` is the same as `BRANCH`, your branch already starts with
that release - it is probably up to date already.

### `fatal: '_...' is not a valid branch name`

`UPGRADED_BRANCH` is missing its release - your details file is not loaded,
or its `TARGET_TAG` line is missing or comes after the `UPGRADED_BRANCH`
line. See [above](#change_me-appears-in-an-error-or-a-value-is-empty).

### `git push` says `Permission denied (publickey)`

See [the SSH problem above](#ssh--t-gitgithubcom-says-permission-denied-publickey).

### `git push` says `Permission to MetOffice/ukca.git denied`

You are pushing to MetOffice, not your fork. Use `origin`:
`git push -u origin "$UPGRADED_BRANCH"`. Check `git remote -v`: `origin` must
show your username.

### There are too many conflicts to sort out

Cancel with `git merge --abort` - the copy is back as it was, and your
original branch was never touched. You can simply stop here: your branch is
still on GitHub as it was. If you do need the upgrade, talk to someone who
knows the code you changed: the conflicts are the same ones an `fcm merge` of
trunk would give, so they need the same care.

## Step 2 - Test your upgraded branch

### The test suite still fails after the merge

Check `dependencies.yaml` (step
[1.4](01-merge-release.md#14-update-dependenciesyaml)): every `ref:` should
be a release such as `2025.12.1`, or your own branch. Old test suite changes
on your branch may also need redoing in the new `.cylc` files.
