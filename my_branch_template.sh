# Your details for moving one FCM branch to GitHub.
#
# Copy this file to ~/fcm_to_git_work/my_branch.sh, then replace each
# CHANGE_ME as you go through the steps. Load it in a terminal with:
#
#   source ~/fcm_to_git_work/my_branch.sh

# Your GitHub username (step 0).
GH_USER=CHANGE_ME

# Your FCM branch address (step 1.2). It starts
# https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/
FCM_URL=CHANGE_ME

# The release your FCM branch started from, e.g. um13.7 (step 1).
# If your branch name starts with r<number>, the git commit hash from
# step 3.1.
START=CHANGE_ME

# You should not need to change anything below this line.
WORK=~/fcm_to_git_work
BRANCH=$(basename "$FCM_URL")
GH_CLONE=$WORK/github/ukca
FCM_TO_GIT=$WORK/fcm_to_git/fcm_to_git.sh
