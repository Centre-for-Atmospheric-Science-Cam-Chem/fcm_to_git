# 0. Before you start

This guide brings a branch that is **already on GitHub** up to a newer
release, e.g. from `um13.7` to `2025.12.1`. You do not need to know git
already - every command is given, with where to run it and what you should
see.

Your branch can have got to GitHub any way - with the
[migration guide](../branch_migration/README.md), with the Met Office's
method, or by starting it on GitHub.

If anything goes wrong, look in [Troubleshooting](troubleshooting.md). It is
organised by step, and you can search it for the error message you see.

## What upgrading does

Upgrading is a **merge**: git combines the changes on your branch with
everything that changed on trunk up to the new release - the same job as
merging trunk into a branch with `fcm merge`. Where your branch and trunk
changed the same lines, git cannot decide which to keep, and asks you: a
**conflict**.

The merge is done on a **copy** of your branch, so your original branch is
never changed:

```
tag um13.7 ──> your branch ─────────────────── (kept as it is)
                    │
                    └── copy ── merge ──> 2025.12.1_<your branch>
                                  │
tag 2025.12.1 ────────────────────┘
```

1. [Merge the new release into a copy of your branch](01-merge-release.md) -
   including fixing any conflicts.
2. [Test your upgraded branch](02-test-upgraded-branch.md).

## What you need

- A **GitHub account**, with an **SSH key** added to it, so that your machine
  can talk to GitHub. If you have not done this, follow GitHub's guide:
  [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).
  On **Monsoon**, SSH to GitHub is blocked - see
  [If SSH to GitHub does not work](#if-ssh-to-github-does-not-work-eg-monsoon).
- [VS Code](https://code.visualstudio.com/) (recommended), which makes fixing
  conflicts much easier. If your machine is remote, use it with the
  [Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) extension.
- From a few minutes to a few days, depending on the conflicts - see
  [How much work is it?](01-merge-release.md#how-much-work-is-it)

## Check your machine is ready

Open a terminal on that machine and run each of these. Each should print what
is shown after it - if not, see
[Troubleshooting: Step 0](troubleshooting.md#step-0---before-you-start).

```bash
git --version
```

prints `git version 2.23` or newer. (Older versions do not have `git switch`.)

```bash
ssh -o ConnectTimeout=10 -T git@github.com
```

prints `Hi <your GitHub username>! You've successfully authenticated, but
GitHub does not provide shell access.` (The first time, it asks
`Are you sure you want to continue connecting?` - type `yes`.) If instead it
says `Connection timed out` after 10 seconds, SSH to GitHub is blocked on
this machine - see
[If SSH to GitHub does not work](#if-ssh-to-github-does-not-work-eg-monsoon).

```bash
git config user.name
git config user.email
```

print your name and email. If they print nothing, set them - use the email of
your GitHub account so your commits are linked to you:

```bash
git config --global user.name "Robert Waters"
git config --global user.email "robert.waters@example.ac.uk"
```

## If SSH to GitHub does not work (e.g. Monsoon)

This guide uses SSH to talk to GitHub. Some machines block it - on
**Monsoon** (including Monsoon3) SSH to GitHub is not available at all, and
`ssh -T git@github.com` hangs or times out.

There you have to use **HTTPS with a GitHub personal access token** instead.
This guide does not cover that yet - see the Met Office's
[GitHub authorisation guide](https://metoffice.github.io/simulation-systems/WorkingPractices/gh_authorisation.html),
or ask for help. If you can, do the upgrade on another machine where SSH to
GitHub works.

## 0.1 Set up your folder

Everything for this guide goes in one folder, `~/branch_upgrade_work`:

```
~/branch_upgrade_work/
├── fcm_to_git/      this guide
├── my_branch.sh     your details (made below)
└── github/          your GitHub clone, if you make a new one (0.4)
```

**Run in:** anywhere

```bash
mkdir -p ~/branch_upgrade_work/github
cd ~/branch_upgrade_work
git clone git@github.com:Centre-for-Atmospheric-Science-Cam-Chem/fcm_to_git.git
cp fcm_to_git/branch_upgrade/my_branch_template.sh my_branch.sh
```

## 0.2 Fill in your details file

`~/branch_upgrade_work/my_branch.sh` holds the details of your branch, so you
do not have to type long names again and again. Open it in a text editor
(e.g. `vi ~/branch_upgrade_work/my_branch.sh` or `nano`) and set:

- `GH_USER` - your GitHub username.
- `REPO_NAME` - `ukca`, `um` or `lfric_apps`.
- `BRANCH` - the name of the branch to upgrade, exactly as on GitHub, e.g.
  `um13.7_transformed_ukca_gpuport_nvtx_calipers`.
- `TARGET_TAG` - the release to upgrade to. Leave it as `2025.12.1` for now;
  see [Which release to merge](01-merge-release.md#which-release-to-merge).
- `GH_CLONE` - only if you **already have a clone** of your fork: its
  folder, e.g. `~/fcm_to_git_work/github/ukca` if you used the migration
  guide. Otherwise leave it - you make a new clone there in 0.4.

The later steps start with:

```bash
source ~/branch_upgrade_work/my_branch.sh
```

This loads your details into the terminal. **Run it again whenever you open a
new terminal, and after you edit the file.** To see a value, use `echo`, e.g.
`echo $UPGRADED_BRANCH`.

## 0.3 Your fork on GitHub

Your branch lives on your **fork** - your own copy of the repository on
GitHub, e.g. `https://github.com/RobWatersMet/ukca`. In a browser, go to
your fork:

1. **Bring `main` up to date.** If it says *This branch is ... commits behind
   MetOffice/ukca:main*, click **Sync fork** > **Update branch**.
2. **Check GitHub Actions are off**, so they do not run (and fail) when you
   push: **Settings** > **Actions** > **General** > **Actions permissions**
   should be **Disable actions**. If not, choose it and click **Save**.

(No fork yet? Your branch must be somewhere else - you need it on your own
fork first. To make a fork, see
[step 2.1 of the migration guide](../branch_migration/02-fork-and-tags.md#21-create-the-fork-on-github).)

## 0.4 Your clone

**If you already have a clone** (and set `GH_CLONE` in 0.2), skip to 0.5.

Otherwise, clone your fork:

**Run in:** anywhere

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$WORK/github"
git clone "git@github.com:$GH_USER/$REPO_NAME.git"
```

**You should see** `Cloning into 'ukca'...` and a few progress lines.

## 0.5 Link your clone to the official repository and get the tags

The releases are **tags** on the official MetOffice repository, which your
clone calls `upstream`. Check whether it has it:

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
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

If there are no `upstream` lines, add it:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git remote add upstream "git@github.com:MetOffice/$REPO_NAME.git"
```

Then download the tags, and check your release is there:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git fetch upstream --tags
git tag --list "$TARGET_TAG"
```

**You should see** your release, e.g. `2025.12.1`.

## 0.6 Check your branch

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git switch "$BRANCH"
git status
```

**You should see:**

```
On branch um13.7_transformed_ukca_gpuport_nvtx_calipers
Your branch is up to date with 'origin/um13.7_transformed_ukca_gpuport_nvtx_calipers'.

nothing to commit, working tree clean
```

(In a new clone, `git switch` first says
`branch '...' set up to track 'origin/...'` - that is fine.) If it lists
changed files, or says your branch is *ahead* or *behind*, see
[Troubleshooting](troubleshooting.md#git-status-lists-changed-files-or-says-ahead-or-behind).

Next: [step 1](01-merge-release.md).
