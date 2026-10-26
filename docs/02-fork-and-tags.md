# 2. Fork UKCA on GitHub and bring across the tags

In this step you:

- make your fork - your own copy of UKCA on GitHub (see
  [step 0](00-before-you-start.md#what-is-a-fork-and-why-do-i-need-one))
- turn off GitHub Actions on it
- clone it onto your computer
- copy the release **tags** (e.g. `um13.7`) into your fork

You only do this once. For your next branch, skip to
[Keeping your fork up to date](#keeping-your-fork-up-to-date).

Problems? See [Troubleshooting: Step 2](troubleshooting.md#step-2---fork-and-tags).

## Why the tags matter

A tag marks a release, e.g. `um13.7`. Your git branch will start from the tag
of the release your FCM branch started from (step 1), so that the only
differences are your own changes. Your fork must have that tag.

GitHub does not always copy tags into a fork, and the **Sync fork** button on
GitHub never does. So we copy them ourselves, in 2.5.

## 2.1 Create the fork on GitHub

In a web browser:

1. Go to <https://github.com/MetOffice/ukca> and log in. (For the UM or
   LFRic Apps, go to <https://github.com/MetOffice/um> or
   <https://github.com/MetOffice/lfric_apps> instead.)
2. Click **Fork** (top right).
3. **Owner:** your username. **Repository name:** leave it as it is (e.g.
   `ukca`).
4. Leave **Copy the main branch only** ticked.
5. Click **Create fork**.

**You should see** your fork, at `https://github.com/<your username>/ukca`.
Near the top left it says *forked from MetOffice/ukca*.

**If you already had a fork**, bring it up to date: on your fork's page, click
**Sync fork** > **Update branch**. (If it says *This branch is up to date with
MetOffice/ukca:main*, there is nothing to do.)

## 2.2 Turn off GitHub Actions on your fork

UKCA has automatic checks (GitHub Actions) that run when code is pushed. They
are meant for the official repository. On your fork they would run when you
push, fail, and email you about it. Turn them off **before pushing anything**:

1. On your fork, click **Settings** (top bar) > **Actions** (left menu) >
   **General**. (Or go to `https://github.com/<your username>/ukca/settings/actions`.)
2. Under **Actions permissions**, choose **Disable actions**.
3. Click **Save**.

If the **Actions** tab of your fork shows a button *I understand my workflows,
go ahead and enable them* - do **not** click it.

## 2.3 Clone your fork onto your computer

**Run in:** `~/fcm_to_git_work/github`

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$WORK/github"
git clone "git@github.com:$GH_USER/$REPO_NAME.git"
```

**You should see** `Cloning into 'ukca'...` and a few progress lines. You now
have the folder `~/fcm_to_git_work/github/ukca` - your clone.

## 2.4 Link your clone to the official repository

Your clone already knows your fork, as `origin`. Add the official repository
as `upstream`:

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git remote add upstream "git@github.com:MetOffice/$REPO_NAME.git"
git remote -v
```

**You should see** four lines - `origin` is your fork, `upstream` is
MetOffice:

```
origin    git@github.com:RobWatersMet/ukca.git (fetch)
origin    git@github.com:RobWatersMet/ukca.git (push)
upstream  git@github.com:MetOffice/ukca.git (fetch)
upstream  git@github.com:MetOffice/ukca.git (push)
```

## 2.5 Copy the tags into your fork

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git fetch upstream --tags
git push origin --tags
```

The first command downloads all the tags from MetOffice to your computer; the
second uploads them to your fork.

**You should see** lines like `* [new tag] um13.7 -> um13.7`. If your fork
already had the tags, the second command just says `Everything up-to-date` -
that is fine too.

## 2.6 Check your release tag is there

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git ls-remote --tags origin "$START"
```

**You should see** one line ending in your release, e.g.
`10b52f1... refs/tags/um13.7`. If it prints nothing, see
[Troubleshooting](troubleshooting.md#my-release-tag-is-not-on-my-fork).

(If your branch name starts with `r`, `START` is still `CHANGE_ME` and this
prints nothing - that is expected. Check `git_migration` instead:
`git ls-remote --tags origin git_migration`.)

You can also see all the tags in a browser at
`https://github.com/<your username>/ukca/tags`.

Next: [step 3](03-create-github-branch.md).

## Keeping your fork up to date

MetOffice adds new releases over time. When you start on another branch:

1. **Bring `main` up to date.** In a browser, go to your fork
   (`https://github.com/<your username>/ukca`). If it says *This branch is
   ... commits behind MetOffice/ukca:main*, click **Sync fork** >
   **Update branch**.
2. **Bring the new tags across.** **Sync fork** does not copy tags, so also
   run (safe to repeat):

   **Run in:** your GitHub clone

   ```bash
   source ~/fcm_to_git_work/my_branch.sh
   cd "$GH_CLONE"
   git fetch upstream --tags
   git push origin --tags
   ```
