# Your details for moving one FCM branch to GitHub.
#
# Copy this file to ~/fcm_to_git_work/my_branch.sh, then replace each
# CHANGE_ME as you go through the steps. Load it in a terminal with:
#
#   source ~/fcm_to_git_work/my_branch.sh

# Your GitHub username (step 0).
GH_USER=CHANGE_ME

# Your FCM branch URL (step 1) - the "URL:" line printed by "fcm info".
FCM_URL=CHANGE_ME

# The release your FCM branch started from, e.g. um13.7 (step 1).
# If it is not a release, the git commit hash from step 3, route B.
START=CHANGE_ME

# You should not need to change anything below this line.
WORK=~/fcm_to_git_work
BRANCH=$(basename "$FCM_URL")
FCM_WC=$WORK/fcm/$BRANCH
GH_CLONE=$WORK/github/ukca
FCM_TO_GIT=$WORK/fcm_to_git/fcm_to_git.sh
