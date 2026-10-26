# 3. Create a GitHub branch for your work

In this step you make a new branch in your GitHub clone, starting from exactly
the code your FCM branch started from. Step 4 then adds your commits to it.

The branch is only on your computer until step 5 - nothing goes to GitHub in
this step.

Problems? See [Troubleshooting: Step 3](troubleshooting.md#step-3---create-the-github-branch).

**Do not** start your branch from `main`. `main` has changes made since the
move to GitHub that your FCM branch has never seen. Bringing your branch up to
date with `main` comes after the move.

## 3.1 Only if your branch name starts with `r`: find the starting commit

**Skip to 3.2 if your branch name starts with a release** (e.g. `um13.7_...`) -
you already set `START` in step 1.

If it starts with a revision, e.g. `r5137_...`, your branch started from trunk
at that revision. Every FCM trunk revision up to the move to GitHub is also a
git commit, so you can find the matching one.

Replace `5137` below with the number from your branch name, then run:

**Run in:** your GitHub clone

```bash
cd ~/fcm_to_git_work/github/ukca
REV=5137
git log --format='commit %H%n%b' git_migration \
  | awk -v rev="$REV" '/^commit /{h=$2} /git-svn-id:/{split($2, a, "@"); if (a[2] + 0 <= rev) {print h; exit}}'
```

**You should see** one long code (a commit hash), e.g.
`30396c7949cbad0cdd7862b0469c2ffdb4f555f1`. This is the last trunk commit at or before your revision.

Copy it into your details file, replacing the `CHANGE_ME` after `START=`:

```bash
START=30396c7949cbad0cdd7862b0469c2ffdb4f555f1
```

and save the file.

## 3.2 Create the branch

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd ~/fcm_to_git_work/github/ukca
git switch -c "$BRANCH" "$START"
```

This makes a new branch named after your FCM branch, starting at `START`, and
switches to it.

**You should see:**

```
Switched to a new branch 'um13.7_transformed_ukca_gpuport_nvtx_calipers'
```

## 3.3 Check

**Run in:** your GitHub clone

```bash
cd ~/fcm_to_git_work/github/ukca
git status
```

**You should see** your branch name and that nothing has changed:

```
On branch um13.7_transformed_ukca_gpuport_nvtx_calipers
nothing to commit, working tree clean
```

Next: [step 4](04-convert-commits.md).

## Background

- The tags and commits in git hold exactly the same code as FCM trunk at the
  same revision. For UKCA this was checked for `um13.7` (r4898), `um13.9`
  (r6356) and `git_migration` (r7497).
- The Met Office has its own
  [branch migration guide](https://metoffice.github.io/simulation-systems/WorkingPractices/branch_migration.html).
  It copies only the final state of your branch into git, as one commit. This
  guide starts from the same code but keeps each of your FCM commits.
