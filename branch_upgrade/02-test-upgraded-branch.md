# 2. Test your upgraded branch

**Testing is up to you** - only you know what your changes do and how to
check them. The merge in step 1 changed the code under your work, so check
your work still does what it did. (A branch migrated with the
[migration guide](../branch_migration/README.md) needs no testing before
this: its script checks the code is exactly the same as on FCM.)

Problems? See [Troubleshooting: Step 2](troubleshooting.md#step-2---test-your-upgraded-branch).

Some suggestions:

1. **Check it builds.**
2. **Run what you ran before.** Whatever you used to check this work on FCM -
   your own suite, a test case, a box model run - run it on both your
   original branch (the old release) and the upgraded copy (the new
   release), and compare. Differences should be explained by the release, not by your
   changes going missing.
3. **Run rose stem if your site can.** If your machine can run the GitHub
   test suite for this repository, run it - see the Met Office
   [testing guide](https://metoffice.github.io/simulation-systems/Development/testing.html).
   The test suites often do not cover research changes, so this is not a
   replacement for 2.
4. **Do not rely on the copy until it runs.** You can still push it in 1.5 -
   e.g. to back it up - but it is not finished until it was successfully
   tested.

## What next

You can carry on working on the copy as on any GitHub branch. When it is ready
to go into UKCA as a pull request, the reviewers will ask you to bring it up
to date with the latest release first - see the Met Office guides on
[branch migration](https://metoffice.github.io/simulation-systems/WorkingPractices/branch_migration.html)
and [updating a branch](https://metoffice.github.io/simulation-systems/WorkingPractices/maintaining_forks.html#updating-branch).
Until then, there is no need to chase `stable`.
