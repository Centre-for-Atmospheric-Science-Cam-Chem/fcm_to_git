# Your details for upgrading one github branch to a new release.

# Your GitHub username (step 0).
GH_USER=CHANGE_ME

# The repository your branch is in: ukca, um or lfric_apps.
REPO_NAME=ukca

# The release to upgrade your branch to - must be a release tag
# e.g. 2025.12.1, the first GitHub release (recommended)
TARGET_TAG=2025.12.1

# Full branch name of
BRANCH=CHANGE_ME

# You should not need to change anything below this line.
WORK=~/fcm_to_git_work

# Step 6 copy: the branch name with its start (e.g. um13.7_, vn12.0_ or
# r5137_) replaced by TARGET_TAG, the code it is then based on.
UPGRADED_BRANCH=${TARGET_TAG}_$(sed -E \
    -e 's/^[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}_//' \
    -e 's/^((um|vn)[0-9.]+|r[0-9]+)_//' <<<"$BRANCH")

GH_CLONE=$WORK/github/$REPO_NAME
