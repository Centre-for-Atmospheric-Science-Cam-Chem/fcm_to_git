# 1. Fork the GitHub repository and bring across the tags

Before any FCM branch can be moved to GitHub you need your own **fork** of the
upstream repository (e.g. [MetOffice/ukca](https://github.com/MetOffice/ukca)),
and that fork must contain the upstream **tags**.

## Why the tags matter

Every FCM branch was created from a release, e.g. `vn13.9` of the UM. On GitHub
each of those releases is a tag (`um13.9`, `2025.12.1`, ...). When your branch
is converted, it is rebuilt **on top of the matching tag**, so that only your
changes appear in the history and in any pull request.

If the tag is missing from your fork, there is nothing to build on, and the
converted branch either fails or carries the whole code base as "your" change.

GitHub does not reliably keep tags in a fork up to date:

- A fork made with **"Copy the main branch only"** (the default) may not have
  every tag.
- The **"Sync fork"** button updates branches only - it never brings across
  tags created upstream after you forked.

So we always copy the tags across ourselves, as in step 4 below.

## Placeholders used below

| Placeholder | Meaning                         | Example     |
|-------------|---------------------------------|-------------|
| `<ORG>`     | Organisation owning the repo    | `MetOffice` |
| `<REPO>`    | Repository name                 | `ukca`      |
| `<USER>`    | Your GitHub username            | `jbloggs`   |

The commands use SSH URLs (`git@github.com:...`). If you have not set up an SSH
key with GitHub, use `https://github.com/...` instead.

## Step 1 - Create the fork on GitHub

1. Go to `https://github.com/<ORG>/<REPO>`.
2. Click **Fork** (top right).
3. Owner: your own account. Repository name: leave as `<REPO>`.
4. Leave **"Copy the main branch only"** ticked - you do not need the other
   upstream branches.
5. Click **Create fork**.

You now have `https://github.com/<USER>/<REPO>`.

## Step 2 - Clone your fork

```bash
git clone git@github.com:<USER>/<REPO>.git
cd <REPO>
```

## Step 3 - Add the upstream repository as a remote

```bash
git remote add upstream git@github.com:<ORG>/<REPO>.git
git remote -v
```

You should see two remotes:

```
origin    git@github.com:<USER>/<REPO>.git (fetch)
origin    git@github.com:<USER>/<REPO>.git (push)
upstream  git@github.com:<ORG>/<REPO>.git (fetch)
upstream  git@github.com:<ORG>/<REPO>.git (push)
```

- `origin` - your fork. You push here.
- `upstream` - the official repository. You only fetch from here.

## Step 4 - Copy the tags from upstream to your fork

```bash
git fetch upstream --tags
git push origin --tags
```

The first command downloads every upstream tag into your local clone; the
second uploads them to your fork. Tags that are already on your fork are
skipped, so this is safe to repeat.

> `git push origin --tags` pushes **all** tags in your local clone. In a fresh
> clone these are only the upstream tags. If you have made your own local tags,
> delete or rename them first so they do not end up on your fork.

## Step 5 - Check the tags arrived

Compare the tags on upstream with the tags on your fork - the two lists should
be identical:

```bash
git ls-remote --tags upstream | sort > upstream_tags.txt
git ls-remote --tags origin | sort > fork_tags.txt
diff upstream_tags.txt fork_tags.txt && echo "All tags present"
```

You can also look at `https://github.com/<USER>/<REPO>/tags`. Make sure the
release your FCM branch was made from (e.g. `um13.9`) is there.

Remove the two `.txt` files afterwards.

## Keeping your fork up to date later

Upstream will add new releases and tags. Whenever you start new work, repeat
step 4 (and optionally sync `main`):

```bash
git fetch upstream --tags
git push origin --tags
git switch main
git merge --ff-only upstream/main
git push origin main
```

## Alternative: the GitHub CLI

If you have [`gh`](https://cli.github.com/) installed and logged in, steps 1-3
are one command, which creates the fork, clones it and sets up `origin` and
`upstream` for you:

```bash
gh repo fork <ORG>/<REPO> --clone --remote
```

Then `cd <REPO>` and carry on from step 4 - `gh` does not copy the tags either.

## Worked example: UKCA

For the user `jbloggs`, after forking `MetOffice/ukca` on GitHub:

```bash
git clone git@github.com:jbloggs/ukca.git
cd ukca
git remote add upstream git@github.com:MetOffice/ukca.git
git fetch upstream --tags
git push origin --tags
git ls-remote --tags origin | grep um13.9
```

The last command should print the `um13.9` tag.
