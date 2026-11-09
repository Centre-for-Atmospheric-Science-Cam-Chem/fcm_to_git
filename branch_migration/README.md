# Migrate an FCM branch to GitHub

Moves your branch from FCM (MOSRS) to your fork on GitHub, **keeping every
commit**. Your git branch starts from the same release as your FCM branch
(e.g. `um13.7`), and has one commit for each of your FCM commits, with the
code exactly as it was on FCM.

The `fcm_to_git.sh` script in this folder copies the commits (step 4).

## Steps

0. [Before you start](00-before-you-start.md) - what forks, clones and
   commits are; what you need; setting up
1. [Find your FCM branch and where it started](01-find-fcm-branch.md)
2. [Fork UKCA on GitHub and bring across the tags](02-fork-and-tags.md)
3. [Create a GitHub branch for your work](03-create-github-branch.md)
4. [Copy your FCM commits onto the git branch](04-convert-commits.md) - runs
   `fcm_to_git.sh`
5. [Review the commits, then push](05-review-and-push.md)

Something not working? See [Troubleshooting](troubleshooting.md).

## Afterwards

Your branch on GitHub still starts from its old FCM release. If you want to
carry on developing it, bring it up to a GitHub release with the
[branch upgrade guide](../branch_upgrade/README.md).
