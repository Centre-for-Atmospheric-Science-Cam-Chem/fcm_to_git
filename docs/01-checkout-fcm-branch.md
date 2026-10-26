# 1. Check out your FCM branch and find its version

Before converting, you need a local copy (working copy) of your FCM branch, and
you need to know roughly which release it is based on, e.g. `um13.7`. That
release is the GitHub tag your branch will be rebuilt on (see
[step 2](02-fork-and-tags.md)).

Run these on a machine where `fcm` works and you can reach the Met Office
Science Repository Service (MOSRS).

## Step 1 - Check out your branch

Use either the FCM keyword:

```bash
fcm co fcm:ukca.x_br/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
```

or the full URL:

```bash
fcm co https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers/
```

Both give the same thing: a directory named after the branch. If you already
have a working copy, bring it up to date and make sure all your changes are
committed to FCM first:

```bash
cd um13.7_transformed_ukca_gpuport_nvtx_calipers
fcm update
fcm status
```

`fcm status` should print nothing. Anything it lists is not on FCM and will not
be converted.

Note the path to this directory - you will need it later.

## Step 2 - Find the version your branch is based on

### The quick answer: the branch name

By convention, FCM branch names start with the release they were made from:

```
um13.7_transformed_ukca_gpuport_nvtx_calipers
^^^^^^
```

This is usually right, but not always - the branch may have been made from a
different revision, or later updated from trunk. Check it with the next step.

### The reliable answer: `fcm branch-info`

From inside your working copy:

```bash
fcm branch-info
```

For the example branch this prints (trimmed):

```
URL: https://code.metoffice.gov.uk/svn/ukca/main/branches/dev/robertwaters/um13.7_transformed_ukca_gpuport_nvtx_calipers
...
Branch Create Rev: 5373
...
Branch Parent: https://code.metoffice.gov.uk/svn/ukca/main/trunk@4898
Merges Avail From Parent: 7497 7479 7308 ...
Merges Avail Into Parent: 5863 5796 5778 ...
```

The line that matters is:

| Line                         | Meaning                                                                   |
|------------------------------|---------------------------------------------------------------------------|
| `Branch Parent: ...@REV`     | The trunk revision your branch was created from - here **4898**           |
| `Last Merge From Parent: ...`| Only present if you have merged trunk into your branch since creating it  |

Use the `Branch Parent` revision: your git branch starts there, and your FCM
commits are then brought across one by one on top of it. If there is a
`Last Merge From Parent` line, your branch has also been updated from trunk
since - those merges are commits on your branch and are brought across with
the rest. (The `Merges Avail ...` lines list revisions not yet merged between
trunk and your branch - ignore them.)

### Turn the revision into a release

List the release keywords of the project and the trunk revision each one
points at:

```bash
fcm keyword-print fcm:ukca.x
```

For UKCA:

```
revision[ukca.x:um13.6] = 4075
revision[ukca.x:um13.7] = 4898
revision[ukca.x:um13.8] = 5509
revision[ukca.x:um13.9] = 6356
...
```

Your version is the **latest release at or before** your revision. The example
branch parent is r4898, which is exactly `um13.7`.

If your revision lies between two releases (e.g. r5000), your branch is not
based on a release. That is fine - write down the revision instead, and use
route B in [step 3](03-create-github-branch.md).

## Step 3 - Write it down

Before moving on, note:

- the path to your working copy
- the branch URL (`fcm info` prints it as `URL:`)
- the `Branch Parent` revision, and the release it matches if any (e.g. `um13.7`)

On GitHub, the matching tag has the same name (e.g. `um13.7`). In
[step 2](02-fork-and-tags.md), check that this tag is on your fork.
