---
name: contracts
description: Use when writing, updating, checking or reading a service's API or cross-service contract, or when a plan or code changes the requests, replies or events a service handles
---

# Contracts

A contract says exactly how others talk to a service: every request it
answers, every reply it sends, every event it publishes or consumes.
Brainstorming and plans in other services build on it without opening
this service's code, and people read it too. So it has to be exact and
plain.

## Where They Live

Each service has two, in its knowledge-base folder (see
devflow:knowledge-base):

```
knowledge-base/<service>/contracts/
  api.md              what the UI calls: gateway → bridge → this service
  cross-service.md    requests other services send, events this service
                      publishes, events it consumes
```

If one is missing, copy it from `template/` in this directory, replace
`<service>` and `<domain>`, and delete the example entries once real
ones exist. Keep the Conventions section as the template has it unless
this service works differently; then say how it does.

## Rules

- **Current state only.** Describe how it works, never how it changed.
  No "was", "now", "new", "previously", "no longer", "deprecated", no
  dates or changelog. Git keeps the history.
- **One entry per request or event, every part filled in.** Write
  "none" where there is none. Never leave a part out or write "TBD".
- **Exact values.** Paths, subjects, field names, types, statuses and
  error codes exactly as they are on the wire. Copy them from the code
  or the plan; never paraphrase them.
- **Say what each field means and its limits:** required or optional,
  allowed values, ranges, formats. "string, the device's id" rather
  than "id".
- **Define types and error codes once**, in their sections, and point
  to them from entries. Two entries never name the same failure
  differently.
- **Plain words.** Write for an engineer on another team who has never
  seen this service. No internal nicknames.

## Updating

Change a contract whenever the requests, replies or events change: add,
edit or remove entries so the file describes the result. When something
stops existing, remove its entry; don't mark it.

- **At plan time** (devflow:writing-plans): update both contracts to
  what the plan will build. Commit them in the knowledge base together
  with the plan, in one commit, so that if the plan is dropped before
  it's built, `git -C <kb> revert <commit>` takes both back.
- **At code time:** check the code against every entry the work
  touched. Where the code is right and the contract is wrong, fix the
  contract; where the contract is right, fix the code. Commit contract
  fixes in the knowledge base as
  `<service>: correct contract for <what>`.

## Events Across Services

A consumed-event entry names the publisher and links to the event's
entry in the publisher's `cross-service.md`. It doesn't copy the
fields. When you write or change one, open the publisher's contract
and check that the subject, body form and delivery match what this
service expects.

When you change a published event, find the services that consume it
with `grep -l '<entity>.<verb>' <kb>/*/contracts/cross-service.md`, and
tell your human partner which ones the change affects.

Raise a mismatch with your human partner. Never fix it quietly in
another service's contract.
