# 1. Check out your FCM branch and find its version

In this step you:

- get an up-to-date copy (checkout) of your FCM branch
- find where your branch started - a release such as `um13.7`, or a trunk
  revision such as r5137
- write both into your details file

The example branch used throughout this guide is
`um13.7_transformed_ukca_gpuport_nvtx_calipers` - use your own branch instead.

Problems? See [Troubleshooting: Step 1](troubleshooting.md#step-1---check-out-your-fcm-branch).

## 1.1 Check out your branch

First make sure `fcm` can log in to MOSRS (see
[step 0](00-before-you-start.md#check-your-machine-is-ready)):

**Run in:** anywhere

```bash
mosrs-cache-password
```

If you do not know your branch's exact name, list your branches (replace
`robertwaters` with your MOSRS username):

**Run in:** anywhere

```bash
fcm ls fcm:ukca.x_br/dev/robertwaters
```

Then check it out into `~/fcm_to_git_work/fcm`. Either with the FCM keyword:

**Run in:** `~/fcm_to_git_work/fcm`

```bash
cd ~/fcm_to_git_work/fcm
fcm co fcm:ukca.x_br/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
```

or with the full address - both do the same:

```bash
cd ~/fcm_to_git_work/fcm
fcm co https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers/
```

This makes a folder named after your branch, e.g.
`~/fcm_to_git_work/fcm/um13.7_transformed_ukca_gpuport_nvtx_calipers`.

## 1.2 Make sure everything is committed to FCM

The conversion copies what is **committed on MOSRS** - not files you have only
changed on your computer. Check for uncommitted changes:

**Run in:** your FCM checkout

```bash
cd ~/fcm_to_git_work/fcm/um13.7_transformed_ukca_gpuport_nvtx_calipers
fcm status
```

**You should see:** nothing at all.

If it lists files, see
[Troubleshooting: `fcm status` lists files](troubleshooting.md#fcm-status-lists-files).

## 1.3 Fill in your branch address

**Run in:** your FCM checkout

```bash
cd ~/fcm_to_git_work/fcm/um13.7_transformed_ukca_gpuport_nvtx_calipers
fcm info
```

**You should see** a line starting `URL:`, e.g.

```
URL: https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
```

Copy everything after `URL: ` into your details file
(`~/fcm_to_git_work/my_branch.sh`), replacing the `CHANGE_ME` after `FCM_URL=`:

```bash
FCM_URL=https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
```

No spaces around the `=`.

## 1.4 Find where your branch started

Your branch name says where it started. FCM branch names begin with either a
release or a trunk revision number:

| Branch name starts with      | Started from                | Put in your details file |
|------------------------------|-----------------------------|--------------------------|
| A release, e.g. `um13.7_...` | the release `um13.7`        | `START=um13.7`           |
| `r` and a number, e.g. `r5137_...` | trunk revision 5137   | leave `START=CHANGE_ME` for now - step 3.1 finds it |

For the example branch, `um13.7_transformed_ukca_gpuport_nvtx_calipers`, that
is:

```bash
START=um13.7
```

If your branch started from a revision number, write the number down (e.g.
5137) - you need it in [step 3.1](03-create-github-branch.md#31-only-if-your-branch-name-starts-with-r-find-the-starting-commit).

You do not need to double-check this: in step 4 the script compares the code
at `START` with the start of your FCM branch, and stops without changing
anything if they differ. It also spots branches made from another branch
rather than from trunk, and tells you what to do.

### If your branch name starts with neither

Find where it started with `fcm branch-info`:

**Run in:** your FCM checkout

```bash
cd ~/fcm_to_git_work/fcm/<your branch name>
fcm branch-info
```

Look for the `Branch Parent:` line, e.g.

```
Branch Parent: https://code.metoffice.gov.uk/svn/ukca/main/trunk@4898
```

The number after `trunk@` is the trunk revision your branch started from -
here 4898. To see if that is a release:

**Run in:** anywhere

```bash
fcm keyword-print fcm:ukca.x
```

```
revision[ukca.x:um13.6] = 4075
revision[ukca.x:um13.7] = 4898
revision[ukca.x:um13.8] = 5509
...
```

If your number is in the list, use that release (here `START=um13.7`).
Otherwise treat it like a branch starting with `r` and that number.

If `Branch Parent` does **not** end in `/trunk@<number>` - e.g. it is
`.../branches/dev/josephwallwork/um13.8_ukca_gpuport@5776` - your branch was
made from someone else's branch. That is fine: in step 4 the script spots this
and tells you which `START` to use - see
[step 4](04-convert-commits.md#if-your-branch-was-made-from-another-branch).

## 1.5 Check your details file

Save the file, then:

**Run in:** anywhere

```bash
source ~/fcm_to_git_work/my_branch.sh
echo "$FCM_URL"
echo "$BRANCH"
echo "$START"
```

**You should see** your branch address, your branch name and your release
(or `CHANGE_ME` if your branch name starts with `r`), e.g.

```
https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
um13.7_transformed_ukca_gpuport_nvtx_calipers
um13.7
```

Next: [step 2](02-fork-and-tags.md).
