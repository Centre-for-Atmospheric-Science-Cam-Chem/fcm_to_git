# 1. Merge the new release into a copy of your branch

In this step you merge a release (`TARGET_TAG`, e.g. `2025.12.1`) into a copy
of your branch.

It works for any release that is newer than your branch: from an FCM release
(e.g. `um13.7`), from a GitHub release (e.g. `2025.12.1` to `2026.07.1`), or
from somewhere in between releases.

Problems? See [Troubleshooting: Step 1](troubleshooting.md#step-1---merge-the-release).

## How much work is it?

For some branches this is quick; for others it is a real job. It depends on
how many files your branch changed that were also changed on trunk. For
example, merging `2025.12.1` into a few real branches migrated from FCM gave:

| Branch                                         | Conflicts |
|------------------------------------------------|-----------|
| UM `vn13.9_ukca_tutorial`                      | none      |
| LFRic Apps `vn2.2.1_ukca_openmp_cpu_port_to_merge` | 1     |
| UM `vn13.7_cariolle_ozone_scheme`              | 6         |
| UKCA `um13.7_transformed_ukca_gpuport_nvtx_calipers` | 25  |

The older your branch, the more work it usually is: from `um13.0`, it is
upgrading across many releases - the same job as upgrading in FCM. It is
safe to try: do 1.1 and 1.2, look at how many conflicts there are, and if it
is too much, cancel (see [Changed your mind?](#changed-your-mind)) - nothing
is lost.

If in trouble, don't be afraid to ask - merging can be challenging.

## Which release to merge

Your details file sets `TARGET_TAG=2025.12.1`. For a branch from FCM, that
is the recommended choice:

- **`2025.12.1`** (recommended) - the first GitHub release. The Met Office
  says branches need to be on at least this release to run the GitHub test
  suites: since the move, they have changed - e.g. a new
  `dependencies.yaml`, `.rc` files renamed to `.cylc`. It is the smallest
  step that gets them. It is only a few commits after `git_migration`, and
  in the branches above it gave exactly the same conflicts as
  `git_migration`.
- **`git_migration`** - the last FCM version of trunk. Choose this only if
  you want trunk up to the move but want to keep the old, FCM-era test suite
  setup. Change the line to `TARGET_TAG=git_migration`.
- **A later release** (see the
  [table of releases](../README.md#releases-and-tags)) - if you need
  something only in that release, or your branch is already on a GitHub
  release. Use a release tag such as `2026.07.1`.

**Do not merge `stable`** (or `main`) for this. `stable` is the *latest*
GitHub release, and it moves on: for the UM it is already `vn14.2`. Merging
it can take your branch much further than it needs to go - e.g. from `vn13.8`
straight to `vn14.2`. Bringing your branch up to the latest release is only
needed for a pull request - see
[What next](02-test-upgraded-branch.md#what-next).

## 1.1 Make a copy of your branch

Do the merge on a **copy** of your branch. Your original branch stays
exactly as it is - e.g. for a branch migrated from FCM, a record of your work
that still matches the old code - and if the merge goes wrong, you just
delete the copy and start again.

The copy is named after your branch, but starting with the release you merge
instead of the old one, because that is the code it will be based on - e.g.
`um13.7_transformed_ukca_gpuport_nvtx_calipers` becomes
`2025.12.1_transformed_ukca_gpuport_nvtx_calipers`. Your details file works
this name out for you, as `UPGRADED_BRANCH`.

First check your branch is clean:

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
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
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git switch -c "$UPGRADED_BRANCH"
```

**You should see:**

```
Switched to a new branch '2025.12.1_transformed_ukca_gpuport_nvtx_calipers'
```

The rest of this step works on the copy.

## 1.2 Merge

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git fetch upstream --tags
git merge -m "Update to $TARGET_TAG" "$TARGET_TAG"
```

There are two possible results.

**It merges cleanly** - the last lines are something like:

```
Merge made by the 'ort' strategy.
 639 files changed, 16188 insertions(+), 12210 deletions(-)
```

Go on to [1.4](#14-update-dependenciesyaml).

**There are conflicts** - places where both your branch and trunk changed the
same lines, so git cannot decide which to keep. It lists them and ends with:

```
CONFLICT (content): Merge conflict in src/control/top_level/atm_step_4A.F90
Automatic merge failed; fix conflicts and then commit the result.
```

Go on to 1.3.

## 1.3 Fix the conflicts

### List the files with conflicts

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
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

### Which side to keep?

Each conflict has two sides:

- **Your branch** (called *current* or *ours*).
- **The release** (called *incoming* or *theirs*), e.g. `2025.12.1`.

A good rule:

- **In files you have not worked on in your development**, take the
  release's version. A conflict can be in such a file because your branch
  touched it along the way - e.g. through an earlier trunk merge, or an edit
  you later undid.
- **In files you have worked on**, look carefully. Usually you need both: the
  release's changes *and* yours. If you are unsure, ask someone who knows
  that code.

To see whether you worked on a file, list the commits on your branch that
changed it:

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git log --oneline --no-merges "$TARGET_TAG..$BRANCH" -- path/to/file
```

If the commits listed are your development work, it is your file. If none
are, or they are only trunk merges (e.g. an `fcm merge` from your FCM days),
take the release's version.

### Fix each file - with VS Code (recommended)

[VS Code](https://code.visualstudio.com/) makes this much easier. Open your
clone in it:

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
code "$GH_CLONE"
```

(If your clone is on a remote machine, connect to it with VS Code's
[Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) extension
instead, then **File > Open Folder** and choose your clone.)

1. Open **Source Control** (the branch icon in the left-hand bar, or
   `Ctrl+Shift+G`). The files with conflicts are listed under
   **Merge Changes**.
2. Click a file. Each conflict is highlighted in colour, with links above it:

   **Accept Current Change | Accept Incoming Change | Accept Both Changes |
   Compare Changes**

   *Current* is your branch; *incoming* is the release.
3. For each conflict, pick one, following the rule above:
   - **Accept Incoming Change** - take the release's version. Use this in
     files you have not worked on.
   - **Accept Current Change** - keep your version.
   - **Accept Both Changes** - keep both, then tidy up by hand. Often right
     in files you have worked on.

   To take one side for a **whole file** at once, press `Ctrl+Shift+P` and
   choose **Merge Conflict: Accept All Incoming** (or
   **Merge Conflict: Accept All Current**).
4. Save the file (`Ctrl+S`), then click the **+** next to it in Source
   Control to mark it as fixed (the same as `git add`). If you change the
   file again after that, it shows up under **Changes** - click its **+**
   again, or the new change is left out of the merge.

For files deleted in the release, see
[A file deleted on trunk](#a-file-deleted-on-trunk) below - they need a
command in the terminal (VS Code has one: **Terminal > New Terminal**).

### Fix each file - without VS Code

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
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git add path/to/the/file.F90
```

**Whole-file shortcuts.** If you want one side for a whole file:

```bash
git checkout --ours path/to/file      # keep your branch's version
git checkout --theirs path/to/file    # take the release's version
git add path/to/file
```

### A file deleted on trunk

A conflict can also say e.g.

```
CONFLICT (modify/delete): rose-stem/site/meto/groups.rc deleted in 2025.12.1 and modified in HEAD.
```

Trunk deleted a file your branch changed. Usually trunk replaced it with
something else, so delete it too (`git rm path/to/file`), and if your change
is still needed, make it in the replacement. If your branch really still needs
the file, keep it (`git add path/to/file`).

### Test suite files and LFRic Apps

**`.rc` and `.cylc` files.** Many `rose-stem` files were renamed
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
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git diff --name-only
git grep -n -e '^<<<<<<< ' -e '^>>>>>>> '
```

**You should see:** nothing from either command. The first lists files not
yet marked as fixed - including files you changed again after marking them
fixed; `git add` each one when you are happy with it. The second finds any
conflict markers left in the code.

In VS Code you can check too: **Merge Changes** and **Changes** in Source
Control should both be empty (everything is under **Staged Changes**), and
searching all files (`Ctrl+Shift+F`) for `<<<<<<<` should find nothing.

### Finish the merge

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git commit --no-edit --cleanup=strip
```

This makes the merge commit, with the message `Update to 2025.12.1`.

### Changed your mind?

Until you run `git commit`, you can cancel the whole merge and get the copy
back exactly as it was:

```bash
git merge --abort
```

To give up on the copy altogether (your original branch is not touched):

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git merge --abort
git switch "$BRANCH"
git branch -D "$UPGRADED_BRANCH"
```

## 1.4 Update `dependencies.yaml`

`dependencies.yaml` lists the other repositories the test suite uses, and
which version of each (`ref:`). Look at yours:

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
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
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git add dependencies.yaml
git commit -m "Pin dependencies for $TARGET_TAG"
```

## 1.5 Push

Look at the result - newest at the top: any commits you made after the merge
(e.g. 1.4), the merge, and below it your branch's own commits
(`--first-parent` hides the trunk commits the merge brought in):

**Run in:** your GitHub clone

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git log --oneline --first-parent -5
```

(Press `q` to get out of the viewer.) Then push the copy to your fork:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git push -u origin "$UPGRADED_BRANCH"
```

**You should see** a line ending
`* [new branch]      2025.12.1_transformed_ukca_gpuport_nvtx_calipers -> 2025.12.1_transformed_ukca_gpuport_nvtx_calipers`.

Your fork now has both branches: the original, and the copy based on the
release. To see everything the merge changed:

```bash
source ~/branch_upgrade_work/my_branch.sh
cd "$GH_CLONE"
git diff --stat "$BRANCH" "$UPGRADED_BRANCH"
```

Next: [step 2 - test your upgraded branch](02-test-upgraded-branch.md).

