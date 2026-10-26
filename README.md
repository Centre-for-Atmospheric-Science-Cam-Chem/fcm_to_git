# fcm_to_git
A tool for converting branches from the old Met Office FCM system to Github

Moves your UKCA branch from FCM (MOSRS) to your fork on GitHub, keeping every
commit. No git knowledge needed - each step gives the commands to run, where to
run them, and what you should see.

## Guide

0. [Before you start](docs/00-before-you-start.md) - what forks, clones and
   commits are; what you need; setting up
1. [Find your FCM branch and where it started](docs/01-find-fcm-branch.md)
2. [Fork UKCA on GitHub and bring across the tags](docs/02-fork-and-tags.md)
3. [Create a GitHub branch for your work](docs/03-create-github-branch.md)
4. [Copy your FCM commits onto the git branch](docs/04-convert-commits.md) - runs `fcm_to_git.sh`
5. [Review the commits, then push](docs/05-review-and-push.md)

Something not working? See [Troubleshooting](docs/troubleshooting.md).

## Other repositories

The guide is written for UKCA, but `fcm_to_git.sh` should work for any FCM
project that has moved to GitHub with its trunk history. It has been tested on
branches of `um` and `lfric_apps` as well as `ukca`. For another project,
replace `ukca` in the commands with the project's name - e.g.
`MetOffice/lfric_apps`, `fcm:lfric_apps.x`. The UM and LFRic Apps tag their
releases `vn13.9`, `vn2.2` and so on, rather than `um13.9`.
