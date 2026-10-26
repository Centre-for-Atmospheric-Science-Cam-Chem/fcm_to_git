# 3. Create a GitHub branch for your work

Your FCM branch now needs a git branch to land on. It must start from exactly
the code your FCM branch started from, so that the only differences are your
own changes.

All commands are run in the clone of your fork from
[step 2](02-fork-and-tags.md).

There are two routes:

- **A - your revision is a release** (from [step 1](01-checkout-fcm-branch.md),
  e.g. `um13.7`): branch from the matching tag.
- **B - your revision is not a release** (e.g. your branch parent lies between
  two releases): branch from the git commit that matches your SVN revision.

Either way, **do not branch from `main`**. `main` contains changes made since
the move to GitHub (new `.github/` workflows, `README.md`, `dependencies.yaml`,
...) that your FCM branch has never seen. Updating to `main` comes later.

## Choose a branch name

Using the FCM branch name keeps the link between the two obvious:

```bash
BRANCH=um13.7_transformed_ukca_gpuport_nvtx_calipers
```

## Route A - Branch from the tag

```bash
git fetch upstream --tags
git switch -c $BRANCH um13.7
```

Replace `um13.7` with your release.

## Route B - Branch from the matching commit

Every SVN trunk revision up to the move to GitHub is a commit in git, and each
of those commits records the revision it came from in its message:

```
git-svn-id: https://metomi/svn/ukca.xm/main/trunk@4898 38b0f608-...
```

Your `Branch Parent` revision from [step 1](01-checkout-fcm-branch.md) may not
be a revision where trunk itself changed -
e.g. `trunk@5000` when trunk last changed at r4898. Trunk at r5000 is the same
code as trunk at r4898, so what you need is the **latest trunk commit at or
before your revision**. This prints it:

```bash
REV=5000
git log git_migration --format='%H %(trailers:key=git-svn-id,valueonly)' \
  | awk -v rev=$REV 'NF {split($2, a, "@"); if (a[2] + 0 <= rev) {print $1; exit}}'
```

Check it is the commit you expect:

```bash
git log -1 <hash>
```

The last line shows the SVN revision, e.g. `.../main/trunk@4898`. Then create
the branch from it:

```bash
git switch -c $BRANCH <hash>
```

## Next

The branch exists only in your local clone for now - do not push it yet.
[Step 4](04-convert-commits.md) adds your FCM commits to it, and you push in
[step 5](05-review-and-push.md) after reviewing them.

## Background

- These git tags and commits contain exactly the same code as SVN trunk at
  the same revision. For UKCA this was checked for `um13.7` (r4898), `um13.9`
  (r6356) and `git_migration` (r7497).
- The Met Office guide to branch migration is
  [here](https://metoffice.github.io/simulation-systems/WorkingPractices/branch_migration.html).
  It copies only the final state of your branch into git (one commit, no
  history). Here we start from the same tagged code but keep your FCM commits.
