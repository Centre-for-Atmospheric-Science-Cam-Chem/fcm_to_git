# 5. Review the commits, then push

After step 4 your commits are only on your computer. In this step you check
them, then push them to your fork on GitHub.

Until you push, nothing is on GitHub - if something looks wrong you can throw
the branch away and start again.

Problems? See [Troubleshooting: Step 5](troubleshooting.md#step-5---review-and-push).

## 5.1 Look at the list of commits

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git log --oneline "$START..$BRANCH"
```

**You should see** one line per FCM commit, newest at the top, each starting
with a short code, then `fcm_to_git` and the original FCM revision, author and
date:

```
d67857b fcm_to_git [r5863 robertwaters 2025-04-02 10:18]: #233 - added the psyclone transformer to the repo directly
1389394 fcm_to_git [r5796 robertwaters 2025-03-24 11:21]: #233 - undoing changes from Edingbugh - no longer needed
e9f4689 fcm_to_git [r5778 robertwaters 2025-03-21 11:47]: revert to original, pre-psyclone1
...
```

If the list is long it opens in a viewer: scroll with the arrow keys, and
press `q` to get back.

## 5.2 Count the commits

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git rev-list --count "$START..$BRANCH"
```

**You should see** the same number as **to convert** in the step 4 dry run,
e.g. `107`. If your branch was made from another branch, add 1 for the extra
first commit.

## 5.3 Look at a commit

To see what one commit changed, use its short code from 5.1:

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git show d67857b
```

**You should see** the commit message with its `FCM-Revision:` line, then the
changes (lines starting `-` were removed, `+` were added). Press `q` to get
back.

To compare with FCM, show the same revision there (use the number from the
`FCM-Revision:` line):

**Run in:** anywhere

```bash
source ~/fcm_to_git_work/my_branch.sh
svn diff -c 5863 "$FCM_URL"
```

The changes should be the same.

## 5.4 Look at everything your branch changes

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git diff --stat "$START" "$BRANCH"
```

**You should see** the files your branch changes, and a summary line such as
`70 files changed, 27718 insertions(+), 27902 deletions(-)`. These should be
your changes and nothing else.

## 5.5 Push to your fork

When you are happy:

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git push -u origin "$BRANCH"
```

This sends your branch to **your fork** (`origin`) - not to MetOffice.

**You should see** some progress lines, ending with

```
 * [new branch]      um13.7_transformed_ukca_gpuport_nvtx_calipers -> um13.7_transformed_ukca_gpuport_nvtx_calipers
branch 'um13.7_transformed_ukca_gpuport_nvtx_calipers' set up to track 'origin/um13.7_transformed_ukca_gpuport_nvtx_calipers'.
```

## 5.6 Check on GitHub

In a browser, go to `https://github.com/<your username>/ukca`, click the
branch menu (it says `main`, top left) and choose your branch. Click the
commit count (clock icon) to see your commits.

Your branch is now on GitHub, with its full history. For most branches,
that's it - you are done.

Optional: [step 6](06-merge-first-release.md) - only if you want to carry on
developing your branch on GitHub.

## If something looks wrong

**Before pushing:** delete the branch and start again from
[step 3](03-create-github-branch.md):

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git switch main
git branch -D "$BRANCH"
```

**After pushing:** it is only on your fork, so you can remove it there too -
see [Troubleshooting](troubleshooting.md#i-pushed-and-want-to-start-again).
