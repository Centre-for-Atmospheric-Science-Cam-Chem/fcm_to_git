# Upgrade a GitHub branch to a new release

Brings a branch that is already on GitHub up to a newer release, e.g. a
branch migrated from FCM at `um13.7` up to `2025.12.1`, the first GitHub
release. The merge is done on a copy of your branch, named after the new
release (e.g. `2025.12.1_transformed_ukca_gpuport_nvtx_calipers`), so your
original branch is never changed.

You need this if you want to carry on developing your branch on GitHub: the
GitHub test suites need at least `2025.12.1`. If you only want your FCM work
kept on GitHub, the [migration guide](../branch_migration/README.md) is
enough.

## Steps

0. [Before you start](00-before-you-start.md) - what upgrading does; what you
   need; your details file, fork and clone
1. [Merge the new release into a copy of your branch](01-merge-release.md) -
   including fixing conflicts
2. [Test your upgraded branch](02-test-upgraded-branch.md)

Something not working? See [Troubleshooting](troubleshooting.md).
