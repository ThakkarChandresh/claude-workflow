---
name: knowledge-base
description: Use when saving or looking up a service's specs, plans, or design docs, when you need another service's code, or when another skill says to put a document in the knowledge base
---

# Knowledge Base

Specs, plans and design docs live in one shared git repo called
`knowledge-base`, not inside each project. Every service gets a folder
there, so work in one repo can read what was decided in another.

## Where It Lives

`knowledge-base` sits in the project's parent folder, next to the
project. The project is the git top-level
(`git rev-parse --show-toplevel`), and the service name is that
folder's name. If the name doesn't look like the service's real name (a
checkout called `app`, say), ask once. Below, `<kb>` is the knowledge
base's path.

```
<parent>/
  <service>/          the project you're in
  knowledge-base/
    README.md
    link-remote.sh
    repos.yaml        every service's git URL, branch and description
    <service>/
      specs/          design docs: YYYY-MM-DD-<topic>-design.md
      plans/          implementation plans
      docs/           other design and reference docs
      contracts/      api.md and cross-service.md (see devflow:contracts)
  references/
    <service>/        a read-only clone of each repo in repos.yaml
```

## First Use

If `<kb>` is a git repo, use it. If it exists but isn't one, stop and
ask what to do.

If it's missing, ask your human partner, in a message of its own,
whether a knowledge-base repo already exists on a remote:

- **It does:** ask for the URL, then clone it with
  `git clone <url> <kb>`.
- **It doesn't:** tell them you're creating it locally, and run
  `bash scripts/init-knowledge-base.sh <kb>`. Then tell them how to
  link it later: create an empty repo on their git host (no README,
  license or .gitignore), then send you its URL or run
  `./link-remote.sh <url>` from inside `<kb>`. When they send a URL,
  run that script for them.

Setting up the knowledge base isn't building. A hard gate on building
doesn't cover it.

## Reading

If `<kb>` has a remote, pull first with `git -C <kb> pull --ff-only`.
If that fails, say so and read what's there.

## Saving

Write into the service's folder, creating it if needed, and commit in
the knowledge base, never in the project. Stage only the files you
wrote:

```
git -C <kb> add <service>/<specs|plans|docs>/<file>
git -C <kb> commit -m "<service>: <what changed>"
```

Push when your human partner or the skill that sent you here says to,
with `git -C <kb> push`. If the push is rejected because the remote has
moved on, run `git -C <kb> pull --rebase` and push again. With no
remote linked yet, skip the push and remind your human partner that the
knowledge base is only local.

If a commit fails because git has no name or email set, ask your human
partner to set them. Never make one up.

## References

`<kb>/repos.yaml` lists every service: its name (also its folder in the
knowledge base and in references), git URL, the branch to read, and a
one-line description.

When to read a service's code is up to your human partner or the skill
that sent you here. To read it:

1. Pick the services whose code you need, using the descriptions in
   `repos.yaml`.
2. Sync the references: dispatch a fresh subagent with
   `sync-references-prompt.md` in this directory. It clones each repo
   in `repos.yaml` that's missing and updates the rest, skipping the
   project you're in. Without a subagent tool, run
   `scripts/sync-references.sh` yourself. Once per session is enough,
   unless the skill that sent you here asks for the latest code.
3. Read only the parts you need from `<parent>/references/<service>/`.
   Never edit, commit or push there.

If a repo fails to sync, tell your human partner which one and why, and
go on with what you have. If `<kb>/repos.yaml` doesn't exist, copy
`template/repos.yaml` from this directory there, and commit it once
your human partner has filled it in.
