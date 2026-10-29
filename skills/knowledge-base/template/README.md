# knowledge-base

Specs, plans and design docs for every service, one folder per service:

```
repos.yaml   every service's git URL, branch and description
<service>/
  specs/     design docs: YYYY-MM-DD-<topic>-design.md
  plans/     implementation plans
  docs/      other design and reference docs
```

The devflow plugin for Claude Code writes and commits here. Keep this
repo in the same folder as your services, so it sits next to them. When
devflow needs another service's code, it clones the repos listed in
`repos.yaml` into a `references/` folder beside this one.

## Listing your repos

Add an entry to `repos.yaml` for each service, following the example at
the top of that file, and commit it.

## Linking a remote

Create an empty repo on your git host (no README, license or
.gitignore), then run this from inside this folder:

```
./link-remote.sh <remote-url>
```
