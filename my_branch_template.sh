# Your details for moving one FCM branch to GitHub.
#
# Copy this file to ~/fcm_to_git_work/my_branch.sh, then replace each
# CHANGE_ME as you go through the steps. Load it in a terminal with:
#
#   source ~/fcm_to_git_work/my_branch.sh

# Your GitHub username (step 0).
GH_USER=CHANGE_ME

# The repository your branch is in: ukca, um or lfric_apps (step 0).
REPO_NAME=ukca

# Your FCM branch address (step 1.2). It starts
# https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/
FCM_URL=CHANGE_ME

# The release your FCM branch started from, e.g. um13.7 (step 1).
# If your branch name starts with r<number>, the git commit hash from
# step 3.1.
START=CHANGE_ME

# Optional step 6: the release to merge into a copy of your branch -
# 2025.12.1, the first GitHub release (recommended), or git_migration, the
# last FCM trunk.
MERGE_TAG=2025.12.1

# You should not need to change anything below this line.
WORK=~/fcm_to_git_work
BRANCH=$(basename "$FCM_URL")
# Step 6 copy: the branch name with its start (e.g. um13.7_, vn12.0_ or
# r5137_) replaced by MERGE_TAG, the code it is then based on.
MERGED_BRANCH=${MERGE_TAG}_$(sed -E 's/^((um|vn)[0-9.]+|r[0-9]+)_//' \
                               <<<"$BRANCH")
GH_CLONE=$WORK/github/$REPO_NAME
FCM_TO_GIT=$WORK/fcm_to_git/fcm_to_git.sh
