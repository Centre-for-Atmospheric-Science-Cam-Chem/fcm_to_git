# fcm_to_git
A tool for converting branches from the old Met Office FCM system to Github

Moves your UKCA branch from FCM (MOSRS) to your fork on GitHub, keeping every
commit. No git knowledge needed - each step gives the commands to run, where to
run them, and what you should see.

## What you end up with

Your branch on GitHub, with every FCM commit, newest at the top - e.g. for
`robertwaters/r5776_ukca_gpuport_nvtx_calipers`:

```
Update to 2025.12.1
fcm_to_git [r6002 robertwaters 2025-04-23 16:17]: #233 - typo
fcm_to_git [r5999 robertwaters 2025-04-23 16:01]: #233 - adding more nvtx to help understand the poor ftoy performance
fcm_to_git [r5978 robertwaters 2025-04-22 16:13]: #233 - more calipers
fcm_to_git [r5974 robertwaters 2025-04-22 14:54]: #233 - typo
fcm_to_git [r5973 robertwaters 2025-04-22 14:44]: #233 - added nvtx calipers to asad chemistry code
...
```

- Each `fcm_to_git [...]` commit is one of your FCM commits (steps 1 to 5),
  with its original revision, author, date and message. The code at each one
  is exactly the code on FCM at that revision.
- `Update to 2025.12.1` at the top is the optional step 6: your work merged
  into the first GitHub release, on a copy of your branch, so you can carry on
  developing it on GitHub.

## Guide

0. [Before you start](docs/00-before-you-start.md) - what forks, clones and
   commits are; what you need; setting up
1. [Find your FCM branch and where it started](docs/01-find-fcm-branch.md)
2. [Fork UKCA on GitHub and bring across the tags](docs/02-fork-and-tags.md)
3. [Create a GitHub branch for your work](docs/03-create-github-branch.md)
4. [Copy your FCM commits onto the git branch](docs/04-convert-commits.md) - runs `fcm_to_git.sh`
5. [Review the commits, then push](docs/05-review-and-push.md)
6. *Optional:* [Bring your branch up to the first GitHub release](docs/06-merge-first-release.md)

Something not working? See [Troubleshooting](docs/troubleshooting.md).

## Other repositories

The guide is written for UKCA, but `fcm_to_git.sh` should work for any FCM
project that has moved to GitHub with its trunk history. It has been tested on
branches of `um` and `lfric_apps` as well as `ukca`. For another project,
set `REPO_NAME` in your details file (see
[step 0](docs/00-before-you-start.md#your-details-file)) to `um` or
`lfric_apps` - the commands then use the right repository. The UM and LFRic Apps tag their
releases `vn13.9`, `vn2.2` and so on, rather than `um13.9`.
