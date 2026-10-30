# Final Review and Finish

Part of devflow:subagent-driven-development. Every task in the plan is
complete.

The final whole-branch review gets a package too: run
`bash scripts/review-package PLAN_FILE MERGE_BASE HEAD` (MERGE_BASE = the commit the
branch started from, e.g. `git merge-base main HEAD`) and include the
printed path in the final review dispatch, so the final reviewer reads
one file instead of re-deriving the branch diff with git commands. Dispatch
on the most capable available model (see SKILL.md's Model Selection), using
devflow:requesting-code-review's
[code-reviewer.md](../../requesting-code-review/code-reviewer.md). Point it at
the ledger's deferred-minor and parked lines so it can triage which must be
fixed before merge.

If the final whole-branch review returns findings, dispatch ONE fix subagent
with the complete findings list — not one fixer per finding.
Per-finding fixers each rebuild context and re-run suites; a real
session's final-review fix wave cost more than all its tasks combined.
Then run exactly one scoped re-review of the fix wave
(`bash scripts/review-package PLAN_FILE FIX_BASE HEAD` over the fix range,
[re-review-prompt.md](../re-review-prompt.md)).
Adjudicate any residual findings as in the fix loop's breaker
(references/fix-loop.md): park with rulings, or rule on the load-bearing
ones and ledger what you decided. Only the four things that stop a running
plan (top of SKILL.md) stop you here. There is no second fix wave —
residual load-bearing findings surface to your human partner in your
final message.

### Check the Contracts

Once the final review and its fix wave are done, check this service's
contracts in the knowledge base (see devflow:contracts) against the code.
Skip it only when no task names a **Contract:** entry and the branch
adds, changes or removes no request, reply or event; ledger
`Contracts: skipped, <why>`.

Run `bash scripts/review-package PLAN_FILE MERGE_BASE HEAD` again, since
the fix wave moved HEAD, and dispatch ONE fresh subagent with
[contract-check-prompt.md](../contract-check-prompt.md). It edits the
contracts to match the code and reports what it changed.

Then:

- **Contract edits:** commit them in the knowledge base, staging only
  the two contract files:
  `git -C <kb> commit -m "<service>: correct contract for <plan>"`.
  Pushing it is your human partner's call, like the branch. Ledger
  `Contracts: <commit7>, <N> edits`.
- **Code that looks wrong:** don't start another fix wave. Ledger each
  one as `Ruling: contract kept, code differs — <entry> at <file:line>`,
  so it reaches your human partner under "Rulings I made".
- **Consumers affected:** ledger each one as a `Ruling:` line naming
  the service and the event.

### Finish

Before you delete anything, collect every ledger line containing `Ruling:` —
preflight rulings, parked findings, breaker adjudications, all of them — into
your final message under "Rulings I made", in the order you made them, each
with what it costs if wrong. The list is exhaustive: if the ledger holds a
ruling, the list holds it. That list is the only place the decisions you
took on your human partner's behalf reach them — they read it and rework
whatever you got wrong. A ruling that dies with the workspace was a decision
made in secret.

When the final whole-branch review is clean and its fixes are merged,
delete this plan's workspace (`rm -rf <workspace>`) — the git history is
the record now. Sibling directories belong to other plans; leave them
alone.

Then report to your human partner and stop: the branch the work is on,
the commits it made, the contract commit in the knowledge base, and
anything parked. Running the full test suite,
merging and pushing are theirs.
