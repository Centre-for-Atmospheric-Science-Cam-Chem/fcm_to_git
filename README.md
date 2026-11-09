# fcm_to_git
Guides and a tool for moving branches from the old Met Office FCM system to
GitHub, and bringing them up to date there.

No git knowledge needed - each step gives the commands to run, where to run
them, and what you should see. Written for UKCA; also tested on the UM and
LFRic Apps (see [Other repositories](#other-repositories)).

## Which guide do I need?

There are two separate jobs. Do one, or both, one after the other:

| You want to...                                                  | Guide |
|-----------------------------------------------------------------|-------|
| Move a branch from FCM to your GitHub fork, keeping every commit | [Migrate an FCM branch to GitHub](branch_migration/README.md) |
| Bring a branch already on GitHub up to a newer release           | [Upgrade a GitHub branch to a new release](branch_upgrade/README.md) |

- **Only want your work kept on GitHub?** Migrating is enough. Your branch
  stays on its old FCM release (e.g. `um13.7`), exactly as it was on FCM.
- **Want to carry on developing it on GitHub?** Migrate it, then upgrade it -
  the GitHub test suites need at least the first GitHub release,
  `2025.12.1`.
- **Already on GitHub** (migrated with this guide, by the Met Office's
  method, or started on GitHub)? Just upgrade.

## What you end up with

After both guides, your branch on GitHub has every FCM commit, newest at the
top - e.g. for `robertwaters/r5776_ukca_gpuport_nvtx_calipers`:

```
Update to 2025.12.1
fcm_to_git [r6002 robertwaters 2025-04-23 16:17]: #233 - typo
fcm_to_git [r5999 robertwaters 2025-04-23 16:01]: #233 - adding more nvtx to help understand the poor ftoy performance
fcm_to_git [r5978 robertwaters 2025-04-22 16:13]: #233 - more calipers
fcm_to_git [r5974 robertwaters 2025-04-22 14:54]: #233 - typo
fcm_to_git [r5973 robertwaters 2025-04-22 14:44]: #233 - added nvtx calipers to asad chemistry code
...
```

- Each `fcm_to_git [...]` commit is one of your FCM commits (from the
  migration guide), with its original revision, author, date and message. The
  code at each one is exactly the code on FCM at that revision.
- `Update to 2025.12.1` at the top is from the upgrade guide: your work
  merged into the first GitHub release, on a copy of your branch, so you can
  carry on developing it on GitHub.

## Releases and tags

Releases are marked by git **tags**. On FCM they were named after UM
versions (`um13.9`, `vn13.9`); on GitHub they are named by date
(`2025.12.1` = December 2025). Every date-named release comes **after**
every FCM one, and each release contains everything before it:

| | UKCA | UM | LFRic Apps |
|---|---|---|---|
| Last FCM releases | `um13.8`, `um13.9` (Jun 2025) | `vn13.8`, `vn13.9` (Jun 2025) | `vn2.1`, `vn2.2` (Jul 2025) |
| Last FCM trunk, not a release | `git_migration` (Oct 2025) | `git_migration` (Oct 2025) | `git_migration` (Nov 2025) |
| **First GitHub release** | `2025.12.1` | `2025.12.1` = `vn14.0` | `2025.12.1` = `vn3.0` |
| | `2026.03.1` = `2026.03.2` | `2026.03.2` = `vn14.1` | `2026.03.1` = `vn3.1` |
| | `2026.07.1` | `2026.07.1` = `vn14.2` | `2026.07.1` = `vn3.2` |

- A migrated branch starts from one of the FCM tags.
- The upgrade guide recommends `2025.12.1`, the first GitHub release, for a
  branch from FCM - e.g. only 22 commits after `um13.9` in UKCA.
- The same date tag goes together across repositories: the UM's `2025.12.1`
  uses UKCA `2025.12.1`. UKCA has no `um14.x` names - `2025.12.1` is the UKCA
  that goes with UM `vn14.0`.
- `stable` is a branch that always points at the latest release (in October
  2026: `2026.07.1` for UKCA and the UM, `2026.07.2` for LFRic Apps).

## Other repositories

The guides are written for UKCA, but `fcm_to_git.sh` should work for any FCM
project that has moved to GitHub with its trunk history. It has been tested on
branches of `um` and `lfric_apps` as well as `ukca`. For another project,
set `REPO_NAME` in your details file to `um` or `lfric_apps` - the commands
then use the right repository. The UM and LFRic Apps tag their FCM releases
`vn13.9`, `vn2.2` and so on, rather than `um13.9`.
