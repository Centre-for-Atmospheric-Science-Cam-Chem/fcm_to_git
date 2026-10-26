# 0. Before you start

This guide moves your UKCA branch from FCM (the old Met Office Subversion
system on MOSRS) to GitHub, **keeping every commit you made**. You do not need
to know git already - every command is given, with where to run it and what
you should see.

If anything goes wrong, look in [Troubleshooting](troubleshooting.md). It is
organised by step, and you can search it for the error message you see.

## How FCM words map to GitHub words

Most ideas are the same, with new names:

| In FCM / SVN                                  | In git / GitHub                         | Notes |
|-----------------------------------------------|-----------------------------------------|-------|
| The UKCA repository on MOSRS                  | The repository `MetOffice/ukca` on GitHub | |
| trunk                                         | `main`                                  | |
| A release keyword, e.g. `um13.7`              | A **tag**, e.g. `um13.7`                | A fixed label on one version of the code |
| A branch                                      | A branch                                | |
| Revision number, e.g. `r5376`                 | A **commit**, named by a code like `1e442b5` | |
| A working copy (`fcm co`)                     | A **clone** (`git clone`)               | A clone holds the whole history, not one revision |
| `fcm commit` - goes straight to MOSRS         | `git commit` - **only on your computer** | Nothing reaches GitHub until you **push** |
| -                                             | `git push`                              | Sends your commits to GitHub |
| -                                             | A **fork**                              | Your own copy of the repository on GitHub - see below |

The big difference: in FCM every commit goes straight to the server. In git,
commits stay on your computer until you `git push`. This guide uses that: the
conversion happens on your computer, you check it, and only then push.

## What is a fork, and why do I need one?

You cannot push to `MetOffice/ukca` directly - only its maintainers can. So
instead you make a **fork**: your own copy of the whole repository on GitHub,
under your account, e.g. `RobWatersMet/ukca`. You push your branches there.

Later, when your work is ready to go into UKCA, you open a **pull request**
from your fork to `MetOffice/ukca` - the equivalent of the FCM ticket and
trunk merge.

`upstream` and `origin` are the names your clone uses for the two GitHub
copies: `upstream` is `MetOffice/ukca`, `origin` is your fork. You only ever
push to `origin`.

## What the steps do

```
FCM:     trunk r4898 ──> your branch: r5376, r5382, ... r5863
                │
             same code
                │
GitHub:  tag um13.7  ──> your branch: one commit per FCM revision
```

1. [Find your FCM branch and where it started](01-find-fcm-branch.md) -
   its address, and which release (e.g. `um13.7`) it started from.
2. [Fork UKCA on GitHub and bring across the tags](02-fork-and-tags.md) -
   your own copy of UKCA, on GitHub and on your computer.
3. [Create a GitHub branch for your work](03-create-github-branch.md) -
   starting from that same release.
4. [Copy your FCM commits onto the git branch](04-convert-commits.md) -
   the `fcm_to_git.sh` script does this.
5. [Review the commits, then push](05-review-and-push.md) - check, then send
   to your fork on GitHub.
6. *Optional:* [Bring your branch up to the first GitHub release](06-merge-first-release.md) -
   only if you want to carry on developing your branch on GitHub.

## What you need

- A **MOSRS account**, and a machine where `fcm` works - the one you normally
  use for FCM. Do **all** the steps on this one machine.
- A **GitHub account**, with an **SSH key** added to it, so that the machine
  can talk to GitHub. If you have not done this, follow GitHub's guide:
  [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).
- About 30 minutes for the first branch.

## Check your machine is ready

Open a terminal on that machine and run each of these. Each should print what
is shown after it - if not, see
[Troubleshooting: Step 0](troubleshooting.md#step-0---before-you-start).

```bash
fcm --version
```

prints a version, e.g. `FCM 2021.05.0`.

```bash
git --version
```

prints `git version 2.23` or newer. (Older versions do not have `git switch`.)

```bash
rsync --version
```

prints a version.

```bash
mosrs-cache-password
```

asks for your MOSRS password and remembers it, so that `fcm` and `svn` can log
in to MOSRS. **Run this each time you log in to the machine** - and whenever
`fcm` or `svn` says `Authentication failed`. Most "it doesn't work" problems
are a forgotten `mosrs-cache-password`.

```bash
svn info https://code.metoffice.gov.uk/svn/ukca/main/trunk
```

prints some lines starting with `Path:`, `URL:`... If it says
`Authentication failed`, run `mosrs-cache-password` again.

```bash
ssh -T git@github.com
```

prints `Hi <your GitHub username>! You've successfully authenticated, but
GitHub does not provide shell access.` (The first time, it asks
`Are you sure you want to continue connecting?` - type `yes`.)

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

## Set up your folders

Everything goes in one folder, `~/fcm_to_git_work`:

```
~/fcm_to_git_work/
├── fcm_to_git/      this guide and the conversion script
├── my_branch.sh     your details (made below)
└── github/          your GitHub clone of UKCA (step 2)
```

**Run in:** anywhere

```bash
mkdir -p ~/fcm_to_git_work/github
cd ~/fcm_to_git_work
git clone git@github.com:Centre-for-Atmospheric-Science-Cam-Chem/fcm_to_git.git
cp fcm_to_git/my_branch_template.sh my_branch.sh
```

## Your details file

`~/fcm_to_git_work/my_branch.sh` holds the details of your branch, so you do
not have to type long names again and again. Open it in a text editor (e.g.
`vi ~/fcm_to_git_work/my_branch.sh` or `nano`). Replace the
`CHANGE_ME` after `GH_USER=` with your GitHub username now. If your branch
is not in UKCA, also change `REPO_NAME=ukca` to `um` or `lfric_apps`. The
other two `CHANGE_ME`s you fill in during step 1.

The later steps start with:

```bash
source ~/fcm_to_git_work/my_branch.sh
```

This loads your details into the terminal. **Run it again whenever you open a
new terminal, and after you edit the file.** To see a value, use `echo`, e.g.
`echo $BRANCH`.
