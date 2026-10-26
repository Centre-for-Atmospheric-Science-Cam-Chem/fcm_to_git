# 4. Copy your FCM commits onto the git branch

In this step the script `fcm_to_git.sh` copies every commit of your FCM branch
onto the git branch from step 3 - one git commit per FCM revision, with the
same message.

It only changes your GitHub clone on your computer. **It never pushes to
GitHub** - that is step 5, after you have checked the result. It does not
change your FCM branch or your FCM checkout.

Problems? See [Troubleshooting: Step 4](troubleshooting.md#step-4---run-fcm_to_gitsh).

## 4.1 Dry run

The script reads your branch from MOSRS, so first make sure `svn` can log in:

**Run in:** anywhere

```bash
mosrs-cache-password
```

Then a dry run with `-n`. It only lists what it would do, and changes
nothing:

**Run in:** anywhere

```bash
source ~/fcm_to_git_work/my_branch.sh
"$FCM_TO_GIT" -n "$FCM_URL" "$GH_CLONE"
```

**You should see** your branch details and a list of your FCM commits:

```
fcm_to_git: FCM branch:  https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
fcm_to_git: git branch:  um13.7_transformed_ukca_gpuport_nvtx_calipers (/home/robertwaters/fcm_to_git_work/github/ukca)
fcm_to_git: created at:  r5373
fcm_to_git: to convert:  107 of 107 revisions
  r5376  Asad code is now version that comes out of psyclone
  r5382  Issue with local char var resolved by upgrading the latest copy of Psyclone
  ...
```

Check:

- There is no `WARNING` - if there is, see
  [If your branch was made from another branch](#if-your-branch-was-made-from-another-branch).
- **FCM branch** is your branch.
- **git branch** is the branch you made in step 3 (named after your FCM
  branch), not `main`.
- The list looks like your commits. Note the **to convert** number - you check
  it again in step 5.

## 4.2 Run it

The same command without `-n`:

**Run in:** anywhere

```bash
source ~/fcm_to_git_work/my_branch.sh
"$FCM_TO_GIT" "$FCM_URL" "$GH_CLONE"
```

It shows one line per commit as it goes. A branch with about 100 commits takes
a couple of minutes.

**You should see** at the end:

```
fcm_to_git: [107/107] r5863 -> 033a7d6  #233 - added the psyclone transformer to the repo directly
fcm_to_git: done - 'um13.7_transformed_ukca_gpuport_nvtx_calipers' matches the FCM branch at r5863
fcm_to_git: nothing has been pushed - review the commits (docs/05-review-and-push.md)
```

`done - ... matches the FCM branch` means the script has checked that the code
on your git branch is exactly the same as the latest code on your FCM branch.

If it stops before this, read the message it prints - it says what to do - and
see [Troubleshooting: Step 4](troubleshooting.md#step-4---run-fcm_to_gitsh). It
is always safe to run the command again: it carries on from where it stopped.

Next: [step 5](05-review-and-push.md).

## If your branch was made from another branch

Most branches are made from trunk. If yours was made from someone else's
branch - even if you did not know - the dry run shows a warning like this:

```
fcm_to_git: WARNING: this FCM branch was not made from trunk, but from another
  branch. It was made from
    /main/branches/dev/josephwallwork/um13.8_ukca_gpuport@5776
  which was made from
    /main/trunk@5509
  The git branch must start from the nearest release:  START=um13.8
  Its first commit then sets the code to /main/branches/dev/josephwallwork/um13.8_ukca_gpuport@5776.
  That commit holds all the changes made on /main/branches/dev/josephwallwork/um13.8_ukca_gpuport
  - not only yours - and they will show up in a pull request.
```

The other branch is not on GitHub, so your git branch cannot start from it.
Instead, the script starts from the nearest release and adds one extra commit
first, which brings the code to the point your branch was made. Your own
commits follow.

What to do:

1. If `START` in your details file is not what the warning says (here
   `um13.8`), change it, then delete your git branch and redo step 3:

   **Run in:** your GitHub clone

   ```bash
   source ~/fcm_to_git_work/my_branch.sh
   cd ~/fcm_to_git_work/github/ukca
   git switch main
   git branch -D "$BRANCH"
   git switch -c "$BRANCH" "$START"
   ```

2. Run the dry run again. The list now starts with the extra commit:

   ```
     r5792  (first commit: code from /main/branches/dev/josephwallwork/um13.8_ukca_gpuport@5776)
     r5794  #233 - removed psyclone processed files, ...
   ```

3. Run the script for real (4.2).

That first commit contains the other branch's changes as well as yours. Before
opening a pull request, talk to the owner of the other branch - their changes
may need to go in first, or with yours.

## What the script does

1. Lists the revisions of your FCM branch. The first one is the copy from
   trunk that created the branch; the rest are your commits.
2. Checks out your FCM branch, as it was when created, into a temporary
   folder, and checks that the git branch holds exactly the same code. If not,
   it stops without changing anything - the git branch was started from the
   wrong place.
3. For each of your FCM revisions:
   - updates the temporary checkout to that revision
   - copies it into your GitHub clone, as in the Met Office guide:
     `rsync -a --delete --exclude=.git --exclude=.svn`
   - commits it with the original message
4. Checks your git branch now holds exactly the same code as the latest
   revision of your FCM branch.

If you add more commits to your FCM branch later, running the script again
copies just the new ones.

## What the commit messages look like

Each commit message is your FCM message. It starts with `fcm_to_git` and the
original revision, author and date (UTC), and ends with the full details of
the original FCM commit:

```
fcm_to_git [r5465 robertwaters 2025-02-18 09:11]: Reverted back to r5460 - added back in openmp

Custom merge into /main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers: r5453 cf. r5460 of /main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers@5464

FCM-URL: https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
FCM-Revision: 5465
FCM-Author: robertwaters
FCM-Date: 2025-02-18T09:11:54Z
```

The git commit itself is made by you (your git name and email), dated when
you ran the script. The original FCM author and date are kept in the message.
The script uses the `FCM-URL` and `FCM-Revision` lines to know where to carry
on if it is run again - do not edit them.
