# Your details for upgrading one GitHub branch to a new release.
#
# Copy this file to ~/branch_upgrade_work/my_branch.sh, then replace each
# CHANGE_ME (step 0). Load it in a terminal with:
#
#   source ~/branch_upgrade_work/my_branch.sh

# Your GitHub username.
GH_USER=CHANGE_ME

# The repository your branch is in: ukca, um or lfric_apps.
REPO_NAME=ukca

# The name of the git branch to upgrade, e.g.
# um13.7_transformed_ukca_gpuport_nvtx_calipers
BRANCH=CHANGE_ME

# The release to upgrade it to - a release tag, e.g. 2025.12.1, the first
# GitHub release (recommended for a branch from FCM).
TARGET_TAG=2025.12.1

# Your GitHub clone. If you already have one - e.g. from the migration
# guide, ~/fcm_to_git_work/github/ukca - put its folder here instead.
GH_CLONE=~/branch_upgrade_work/github/$REPO_NAME

# You should not need to change anything below this line.
WORK=~/branch_upgrade_work
# The upgraded copy: the branch name with its start (e.g. um13.7_, vn12.0_,
# r5137_ or 2025.12.1_) replaced by TARGET_TAG, the code it is then based on.
UPGRADED_BRANCH=${TARGET_TAG}_$(sed -E \
    -e 's/^[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}_//' \
    -e 's/^((um|vn)[0-9.]+|r[0-9]+)_//' <<<"$BRANCH")
