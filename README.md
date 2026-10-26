# fcm_to_git
A tool for converting branches from the old Met Office FCM system to Github

Moves your UKCA branch from FCM (MOSRS) to your fork on GitHub, keeping every
commit. No git knowledge needed - each step gives the commands to run, where to
run them, and what you should see.

## Guide

0. [Before you start](docs/00-before-you-start.md) - what forks, clones and
   commits are; what you need; setting up
1. [Check out your FCM branch and find its version](docs/01-checkout-fcm-branch.md)
2. [Fork UKCA on GitHub and bring across the tags](docs/02-fork-and-tags.md)
3. [Create a GitHub branch for your work](docs/03-create-github-branch.md)
4. [Copy your FCM commits onto the git branch](docs/04-convert-commits.md) - runs `fcm_to_git.sh`
5. [Review the commits, then push](docs/05-review-and-push.md)

Something not working? See [Troubleshooting](docs/troubleshooting.md).
