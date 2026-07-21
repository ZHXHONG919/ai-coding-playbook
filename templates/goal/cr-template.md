# CR <slice-id> Round <n>

Reviewer kind: subagent / external / self
Reviewer role: Domain / Architecture / FE / Backend / DB / AI Pipeline / Delivery / Release
Slice: <slice-id>
Task IDs: <task-ids>
Date: <YYYY-MM-DD>

## Inputs

- Goal: `.goal/GOAL.md`
- Slice: `.goal/slices.yaml#<slice-id>`
- Acceptance: `.goal/acceptance.md`
- Design handoff: `.goal/design-handoff.md`
- Implementation report: `.goal/runs/<slice>-<role-or-main-thread>-<n>.md`
- Validation report: `.goal/validation/<slice>-<kind>-<n>.md`
- Mock ledger: `.goal/mock-ledger.md`
- TODO ledger: `.goal/todo-ledger.md`
- Worktree plan: `.goal/worktree-plan.md`
- Diff / commit:

## Scope Audit

| Check | Result | Evidence |
| --- | --- | --- |
| Implementation stayed inside slice scope | pending | |
| No unauthorized shared contract changes | pending | |
| Mock ledger updated | pending | |
| Local pending questions / demand changes routed to TODO ledger when non-blocking | pending | |
| Worktree merge policy followed | pending / n/a | |
| UI Drift Gate reviewed when frontend changed | pending / passed / skipped / blocking | |

## Tests Run

| Command | Result | Notes |
| --- | --- | --- |
| | pending | |

## Validation Reports

| Report | Kind | Result | Notes |
| --- | --- | --- | --- |
| | contract / smoke / ui-drift / mock-ledger / global-exit | pending | |

## UI Drift Review

Required when the slice or CR fix touches frontend page, admin tool, workflow UI, form, table, review flow, or complex UI state.

| Item | Result | Evidence |
| --- | --- | --- |
| UI baseline includes `ui-flow.md` / `prototype/` / Open Design artifact when applicable | pending / passed / skipped | |
| Open Design baseline tuple recorded when applicable | pending / passed / skipped | projectId + runId if any + studioUrl/previewUrl + entryFile + artifact bundle file list/path |
| Impeccable command or skipped reason recorded | pending / passed / skipped | |
| `UI Drift: Passed / Fixed / Blocking / Skipped` recorded | pending / passed / blocking | |
| No change to confirmed main path, review object, permissions, state flow, or API/ViewModel contract | pending / passed / blocking | |

## Acceptance Coverage

| Acceptance ID | Status | Evidence |
| --- | --- | --- |
| | pending | |

## Findings

| ID | Severity | Finding | Required action | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| | P0 / P1 / P2 / Nit / Blocker / Should-fix | | describe required fix / rejection evidence / follow-up / later slice / release gate / human action | open / fixed / rejected_false_positive / non_blocking_follow_up / later_slice_gate / release_gate / human_intervention | |

## TODO Ledger Routing

Use this for local pending questions, demand improvements, UX suggestions, contract improvements, and tech debt that do not break current P0/P1 acceptance, data correctness, permissions, or state correctness.

| TODO ID | Source finding | Current impact | Latest alignment point | Suggested handling | Ledger status |
| --- | --- | --- | --- | --- | --- |
| | | non-blocking / blocking reason | R99 / goal-end / next kickoff | follow-up slice / backlog / drop | open / closed |

## Human Intervention Candidates

Only list findings that agent cannot resolve independently.

| ID | Reason agent cannot resolve | Required human action | Code TODO | Status |
| --- | --- | --- | --- | --- |

## Summary

- Blocker count: 0
- Blocking findings: 0
- Non-blocking follow-ups: 0
- TODO ledger items opened: 0
- Human intervention count: 0
- Merge recommendation: yes / no
