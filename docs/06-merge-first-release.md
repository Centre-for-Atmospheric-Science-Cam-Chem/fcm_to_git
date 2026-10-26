# 6. Optional: bring your branch up to the first GitHub release

Your branch is now on GitHub, but it is still based on the old release it
started from (e.g. `um13.7`). In this step you merge in `2025.12.1` - the
first release made on GitHub - into a copy of your branch.

**This step is optional.** Most branches stop after step 5: your branch and
its full history are on GitHub, as exactly the same code as on FCM.

Do this step only if you want to carry on developing your branch on GitHub.
The Met Office says branches need to be on at least the first GitHub release
to run the GitHub test suites. Since the move, the test suites have changed -
e.g. a new `dependencies.yaml`, `.rc` files renamed to `.cylc` - and
`2025.12.1` is the first release with those changes.

Problems? See [Troubleshooting: Step 6](troubleshooting.md#step-6---merge-a-release).

## How much work is it?

For some branches this is quick; for others it is a real job. It depends on
how many files your branch changed that were also changed on trunk. For
example, merging `2025.12.1` into a few real branches gave:

| Branch                                         | Conflicts |
|------------------------------------------------|-----------|
| UM `vn13.9_ukca_tutorial`                      | none      |
| LFRic Apps `vn2.2.1_ukca_openmp_cpu_port_to_merge` | 1     |
| UM `vn13.7_cariolle_ozone_scheme`              | 6         |
| UKCA `um13.7_transformed_ukca_gpuport_nvtx_calipers` | 25  |

The older your branch, the more work it usually is: from `um13.0`, it is
upgrading across many releases - the same job as upgrading in FCM. It is
safe to try: do 6.1 and 6.2, look at how many conflicts there are, and if it
is too much, cancel (see [Changed your mind?](#changed-your-mind)) - nothing
is lost.

## Which release to merge

Your details file sets `MERGE_TAG=2025.12.1`. That is the recommended choice:

- **`2025.12.1`** (recommended) - the first GitHub release. The smallest step
  that gets the GitHub test suites. It is only a few commits after
  `git_migration`, and in the branches above it gave exactly the same
  conflicts as `git_migration`.
- **`git_migration`** - the last FCM version of trunk. Choose this only if
  you want trunk up to the move but want to keep the old, FCM-era test suite
  setup. Change the line to `MERGE_TAG=git_migration`.

**Do not merge `stable`** (or `main`) for this. `stable` is the *latest*
GitHub release, and it moves on: for the UM it is already `vn14.2`. Merging
it can take your branch much further than it needs to go - e.g. from `vn13.8`
straight to `vn14.2`. Bringing your branch up to the latest release is only
needed for a pull request - see [What next](#what-next).

## 6.1 Make a copy of your branch

Do the merge on a **copy** of your branch. Your migrated branch stays exactly
as it came from FCM - a record of your work that still matches the old code -
and if the merge goes wrong, you just delete the copy and start again.

The copy is named after your branch, but starting with the release you merge
instead of the old one, because that is the code it will be based on - e.g.
`um13.7_transformed_ukca_gpuport_nvtx_calipers` becomes
`2025.12.1_transformed_ukca_gpuport_nvtx_calipers`. Your details file works
this name out for you, as `MERGED_BRANCH`.

If your details file was made before step 6 was added, it has no
`MERGE_TAG` or `MERGED_BRANCH` lines - add these to the end of
`~/fcm_to_git_work/my_branch.sh`:

```bash
MERGE_TAG=2025.12.1
MERGED_BRANCH=${MERGE_TAG}_$(sed -E 's/^((um|vn)[0-9.]+|r[0-9]+)_//' \
                               <<<"$BRANCH")
```

First check your branch is clean:

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git switch "$BRANCH"
git status
```

**You should see:**

```
On branch um13.7_transformed_ukca_gpuport_nvtx_calipers
Your branch is up to date with 'origin/um13.7_transformed_ukca_gpuport_nvtx_calipers'.

nothing to commit, working tree clean
```

Then make the copy and switch to it:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git switch -c "$MERGED_BRANCH"
```

**You should see:**

```
Switched to a new branch '2025.12.1_transformed_ukca_gpuport_nvtx_calipers'
```

The rest of this step works on the copy.

## 6.2 Merge

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git fetch upstream --tags
git merge --no-edit "$MERGE_TAG"
```

There are two possible results.

**It merges cleanly** - the last lines are something like:

```
Merge made by the 'ort' strategy.
 639 files changed, 16188 insertions(+), 12210 deletions(-)
```

Go on to [6.4](#64-update-dependenciesyaml).

**There are conflicts** - places where both your branch and trunk changed the
same lines, so git cannot decide which to keep. It lists them and ends with:

```
CONFLICT (content): Merge conflict in src/control/top_level/atm_step_4A.F90
Automatic merge failed; fix conflicts and then commit the result.
```

Go on to 6.3.

## 6.3 Fix the conflicts

### List the files with conflicts

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git diff --name-only --diff-filter=U
```

**You should see** just the files you need to fix, e.g.

```
rose-meta/um-atmos/versions.py
rose-stem/site/meto/groups.rc
rose-stem/site/meto/tasks-ex1a.cylc
rose-stem/site/meto/variables_xc40.rc
src/atmosphere/radiation_control/rad_input_mod.F90
src/control/top_level/atm_step_4A.F90
```

(`git status` shows them too, under *Unmerged paths*, but also lists every
file that merged without problems.)

If there are more than you want to deal with, you can stop here - see
[Changed your mind?](#changed-your-mind).

### Fix each file

Open each file in your editor and search for `<<<<<<<`. Each conflict looks
like this:

```
<<<<<<< HEAD
  your branch's version of the lines
=======
  trunk's version of the lines (from the release)
>>>>>>> 2025.12.1
```

Edit it to what the code should be - your version, trunk's version, or a mix
of both - and delete the three marker lines (`<<<<<<<`, `=======`,
`>>>>>>>`). Then mark the file as fixed:

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git add path/to/the/file.F90
```

**Whole-file shortcuts.** If you know you want one side for a whole file:

```bash
git checkout --ours path/to/file      # keep your branch's version
git checkout --theirs path/to/file    # take the release's version
git add path/to/file
```

**A file deleted on trunk.** A conflict can also say e.g.

```
CONFLICT (modify/delete): rose-stem/site/meto/groups.rc deleted in 2025.12.1 and modified in HEAD.
```

Trunk deleted a file your branch changed. Usually trunk replaced it with
something else, so delete it too (`git rm path/to/file`), and if your change
is still needed, make it in the replacement. If your branch really still needs
the file, keep it (`git add path/to/file`).

**Test suite files (`.rc` and `.cylc`).** Many `rose-stem` files were renamed
from `.rc` to `.cylc`. Git usually follows the rename, so a conflict can show
up in the new `.cylc` file (e.g. `tasks-ex1a.cylc` above) - fix it as usual.
Where the old `.rc` file was replaced rather than renamed, you get a "deleted"
conflict like the one above.

**LFRic Apps:** if the merge says `dependencies.sh deleted in 2025.12.1`,
delete it too (`git rm dependencies.sh`) - it is replaced by
`dependencies.yaml`.

### Check you got them all

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git diff --name-only --diff-filter=U
git grep -n -e '^<<<<<<< ' -e '^>>>>>>> '
```

**You should see:** nothing from either command. The first lists files not
yet marked as fixed; the second finds any conflict markers left in the code.

### Finish the merge

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git commit --no-edit
```

This makes the merge commit, with the message
`Merge tag '2025.12.1' into <your branch>`.

### Changed your mind?

Until you run `git commit`, you can cancel the whole merge and get the copy
back exactly as it was:

```bash
git merge --abort
```

To give up on the copy altogether (your migrated branch is not touched):

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git merge --abort
git switch "$BRANCH"
git branch -D "$MERGED_BRANCH"
```

## 6.4 Update `dependencies.yaml`

`dependencies.yaml` lists the other repositories the test suite uses, and
which version of each (`ref:`). Look at yours:

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
cat dependencies.yaml
```

Check two things:

- **Every `ref:` is a fixed release**, e.g. `ref: 2025.12.1`. For the UM and
  LFRic Apps they already are. In **UKCA** `2025.12.1`, `SimSys_Scripts` has
  `ref: main`, which keeps moving - change it to `ref: 2025.12.1` so your
  tests use the scripts from the same release:

  ```yaml
  SimSys_Scripts:
      source: git@github.com:MetOffice/SimSys_Scripts.git
      ref: 2025.12.1
  ```

- **If your work spans several repositories** (e.g. a UM branch that needs
  your UKCA branch), point those entries at your own branches - set `source:`
  to your fork and `ref:` to your branch name. See the Met Office guide to
  [multi-repo testing](https://metoffice.github.io/simulation-systems/Development/TestSuites/multi-repo_testing.html).

Leave the entry for the repository you are in (e.g. `ukca:` in UKCA) with
empty `source:` and `ref:` - that means "this clone".

If you changed it, commit the change:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git add dependencies.yaml
git commit -m "Pin dependencies for $MERGE_TAG"
```

## 6.5 Check and push

Check your branch builds and its tests run before pushing.

Look at the result - your commits are at the top, and below them the merge
and your FCM commits (`--first-parent` hides the trunk commits the merge
brought in):

**Run in:** your GitHub clone

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git log --oneline --first-parent -5
```

(Press `q` to get out of the viewer.) Then push the copy to your fork:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git push -u origin "$MERGED_BRANCH"
```

**You should see** a line ending
`* [new branch]      2025.12.1_transformed_ukca_gpuport_nvtx_calipers -> 2025.12.1_transformed_ukca_gpuport_nvtx_calipers`.

Your fork now has both branches: the migrated one, and the copy based on the
release. To see everything the merge changed:

```bash
source ~/fcm_to_git_work/my_branch.sh
cd "$GH_CLONE"
git diff --stat "$BRANCH" "$MERGED_BRANCH"
```

## What next

You can carry on working on the copy as on any GitHub branch. When it is ready
to go into UKCA as a pull request, the reviewers will ask you to bring it up
to date with the latest release first - see the Met Office guides on
[branch migration](https://metoffice.github.io/simulation-systems/WorkingPractices/branch_migration.html)
and [updating a branch](https://metoffice.github.io/simulation-systems/WorkingPractices/maintaining_forks.html#updating-branch).
Until then, there is no need to chase `stable`.
