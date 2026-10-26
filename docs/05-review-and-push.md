# 5. Review the commits, then push

After [step 4](04-convert-commits.md) your commits exist only in your local
clone. Check them before anything goes to GitHub - until you push, everything
can be thrown away and redone.

Set these to match your branch:

```bash
BRANCH=um13.7_transformed_ukca_gpuport_nvtx_calipers
START=um13.7    # the tag or commit hash the branch was created from in step 3
```

## Check the commits

List the new commits - one per FCM revision, oldest at the bottom:

```bash
git log --oneline $START..$BRANCH
```

Count them. This should equal the number of revisions on your FCM branch,
minus the one that created it (the `to convert` count from step 4):

```bash
git rev-list --count $START..$BRANCH
```

Look at individual commits, e.g. the first and last:

```bash
git show --stat $BRANCH~0
git log --reverse --format=%H $START..$BRANCH | head -1 | xargs git show --stat
```

Compare any commit with the SVN revision it came from (the revision is on the
`FCM-Revision:` line of the message):

```bash
git show <hash>
svn diff -c <revision> <FCM branch URL>
```

## Check the total change

Everything your branch changes compared with where it started:

```bash
git diff --stat $START $BRANCH
```

This should look like your FCM branch's changes, and nothing else - compare
with `fcm diff -b` in your FCM working copy.

## If something is wrong

Nothing is on GitHub yet, so delete the branch and start again from
[step 3](03-create-github-branch.md):

```bash
git switch main
git branch -D $BRANCH
```

## Push

When you are happy:

```bash
git push -u origin $BRANCH
```

This pushes to **your fork** (`origin`), not to the upstream repository.
`-u` links your local branch to the one on your fork, so later you can just run
`git push`. The branch is then at
`https://github.com/<USER>/<REPO>/tree/<BRANCH>`.

Check on GitHub that the commits are there. GitHub Actions should not run,
because they were disabled on your fork in [step 2](02-fork-and-tags.md).
