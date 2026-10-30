# Contract Check Prompt Template

Use this template when dispatching the contract check, after the final
whole-branch review and its fix wave. The checker compares this
service's contracts with the code the branch built and fixes the
contracts where they don't match it.

**Purpose:** Leave `api.md` and `cross-service.md` describing exactly
what the code does.

```
Subagent (general-purpose):
  description: "Check contracts against the code"
  model: [MODEL — REQUIRED: choose per SKILL.md Model Selection; an omitted
         model silently inherits the session's most expensive one]
  prompt: |
    You are checking this service's contracts against the code a branch
    just built, and fixing the contracts where they are wrong. Invoke
    devflow:contracts first and follow its rules for every edit.

    ## The Contracts

    - [API_CONTRACT]
    - [CROSS_SERVICE_CONTRACT]

    ## The Work

    The plan: [PLAN_FILE]
    The entries its tasks named under **Contract:**:

    [CONTRACT_ENTRIES]

    The whole branch, as one diff file: [DIFF_FILE]
    Read it once. The code is in this checkout; open any file the diff
    touches when you need more than the diff shows.

    ## What to Check

    Check every entry listed above, and every request, reply or event
    the diff adds, changes or removes even if no task named it. For each,
    compare with the code: path and method, subject, query, body,
    success, every error status and code, and for events the subject,
    body form, delivery, event id and fields.

    - **The code differs and the code is what the plan meant:** edit the
      contract to match the code.
    - **The code handles a request, reply or event the contract lacks:**
      add the entry.
    - **The contract has an entry the code no longer serves:** remove it.
    - **The code differs and looks wrong** (it contradicts the plan or
      the spec): leave the contract as it is and report it. Never change
      the code.

    Edit only the two contract files above. Never edit another service's
    contract. If a change here breaks what a consumer expects (check
    with `grep -l '<entity>.<verb>' [KB]/*/contracts/cross-service.md`),
    report it. Don't commit; the controller commits.

    ## You Do Not Dispatch Subagents

    Do all of this check yourself. Never spawn a subagent.

    ## Output Format

    Your final message is the report itself, with no preamble.

    ### Contract Edits

    One line per edit: file › entry heading — what you changed, and the
    code it matches (file:line). "None" if none.

    ### Code That Looks Wrong

    One line per mismatch you left: file › entry heading — what the
    contract says, what the code does (file:line). "None" if none.

    ### Consumers Affected

    Services whose consumed-event entries no longer match. "None" if none.
```

**Placeholders:**
- `[MODEL]` — REQUIRED: a standard model; the most capable one when the
  branch changes many requests or events
- `[API_CONTRACT]`, `[CROSS_SERVICE_CONTRACT]` — paths to
  `<kb>/<service>/contracts/api.md` and `cross-service.md`
- `[PLAN_FILE]` — the plan's path
- `[CONTRACT_ENTRIES]` — every **Contract:** line from the plan's tasks,
  one per bullet; "none named" if the plan has none
- `[DIFF_FILE]` — the path `bash scripts/review-package PLAN_FILE MERGE_BASE HEAD` printed
- `[KB]` — the knowledge base's path

**Checker returns:** the contract edits it made, the code it thinks is
wrong, and the consumers affected.
