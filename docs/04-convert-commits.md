# 4. Copy your FCM commits onto the git branch

`fcm_to_git.sh` (at the top of this repository) copies every commit of your FCM
branch onto the git branch from [step 3](03-create-github-branch.md), one git
commit per SVN revision, keeping the original messages.

It only works in your local git clone. **It never pushes** - that is
[step 5](05-review-and-push.md), after you have reviewed the result.

## What it does

1. Lists the revisions of your FCM branch (`svn log --stop-on-copy`). The first
   one is the copy from trunk that created the branch; the rest are your
   commits.
2. Checks out the branch, at the revision it was created, into a temporary
   directory, and checks the git branch holds exactly the same code. If not, it
   stops - the git branch was made from the wrong tag or commit.
3. For each revision:
   - updates the temporary checkout to that revision
   - copies it into the git clone, as in the Met Office guide:
     `rsync -a --delete --exclude=.git --exclude=.svn`
   - commits it with the original SVN message
4. Checks the git branch now holds exactly the same code as the last revision
   of your FCM branch.

Your own FCM working copy is not touched.

## Commit messages

Each commit message is the SVN message, prefixed with `fcm_to_git:`, followed
by details of the original SVN commit:

```
fcm_to_git: Reverted back to r5460 - added back in openmp

Custom merge into /main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers: r5453 cf. r5460 of /main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers@5464

FCM-URL: https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
FCM-Revision: 5465
FCM-Author: robertwaters
FCM-Date: 2025-02-18T09:11:54Z
```

The git author is you (from `git config user.name` / `user.email`); the author
date is the date of the original SVN commit.

## Before you run it

- You have the git branch from [step 3](03-create-github-branch.md) checked out,
  with no uncommitted changes.
- `svn` works and can reach MOSRS (try `svn info <branch URL>`).
- Your git name and email are set: `git config user.name` and
  `git config user.email`.
- `rsync` is installed.

## Run it

First do a dry run (`-n`). It lists the revisions that would be copied, without
changing anything:

```bash
/path/to/fcm_to_git/fcm_to_git.sh -n <FCM branch URL or working copy> <git clone>
```

For the example branch:

```bash
cd ~/ukca    # your clone, on the branch from step 3
/path/to/fcm_to_git/fcm_to_git.sh -n \
  https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers .
```

```
fcm_to_git: FCM branch:  https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
fcm_to_git: git branch:  um13.7_transformed_ukca_gpuport_nvtx_calipers (/home/jbloggs/ukca)
fcm_to_git: created at:  r5373
fcm_to_git: to convert:  107 of 107 revisions
  r5376  Asad code is now version that comes out of psyclone
  r5382  Issue with local char var resolved by upgrading the latest copy of Psyclone
  ...
```

Then run it for real by dropping `-n`:

```bash
/path/to/fcm_to_git/fcm_to_git.sh \
  https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers .
```

```
fcm_to_git: checking out r5373 ...
fcm_to_git: [1/107] r5376 -> 1e442b5  Asad code is now version that comes out of psyclone
fcm_to_git: [2/107] r5382 -> 6ba7648  Issue with local char var resolved by upgrading the latest copy of Psyclone
...
fcm_to_git: [107/107] r5863 -> 096766b  #233 - added the psyclone transformer to the repo directly
fcm_to_git: done - 'um13.7_transformed_ukca_gpuport_nvtx_calipers' matches the FCM branch at r5863
fcm_to_git: nothing has been pushed - review the commits (docs/05-review-and-push.md)
```

The example branch (107 revisions) takes about two minutes.

## If it stops part way

Just run it again. It finds the last revision already copied (from the
`FCM-Revision:` line) and carries on from the next one. If you commit more to
the FCM branch later, running it again copies only the new revisions.

## If it says the branch does not match

```
fcm_to_git: ERROR: git branch '...' does not match the FCM branch at r5373.
```

The git branch was not created from the code your FCM branch started from.
Check the `Branch Parent` revision ([step 1](01-checkout-fcm-branch.md)),
delete the git branch and create it again ([step 3](03-create-github-branch.md)):

```bash
git switch main
git branch -D <branch>
```
