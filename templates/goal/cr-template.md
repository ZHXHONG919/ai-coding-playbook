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
- Worker report: `.goal/runs/<slice>-<role>-<n>.md`
- Validation report: `.goal/validation/<slice>-<kind>-<n>.md`
- Mock ledger: `.goal/mock-ledger.md`
- Worktree plan: `.goal/worktree-plan.md`
- Diff / commit:

## Scope Audit

| Check | Result | Evidence |
| --- | --- | --- |
| Worker stayed inside slice scope | pending | |
| No unauthorized shared contract changes | pending | |
| Mock ledger updated | pending | |
| Worktree merge policy followed | pending / n/a | |

## Tests Run

| Command | Result | Notes |
| --- | --- | --- |
| | pending | |

## Validation Reports

| Report | Kind | Result | Notes |
| --- | --- | --- | --- |
| | contract / smoke / mock-ledger / global-exit | pending | |

## Acceptance Coverage

| Acceptance ID | Status | Evidence |
| --- | --- | --- |
| | pending | |

## Findings

| ID | Severity | Finding | Required action | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| | Blocker / Should-fix / Nit | | describe required fix / rejection evidence / human action | open / fixed / rejected_false_positive / human_intervention | |

## Human Intervention Candidates

Only list findings that agent cannot resolve independently.

| ID | Reason agent cannot resolve | Required human action | Code TODO | Status |
| --- | --- | --- | --- | --- |

## Summary

- Blocker count: 0
- Open findings: 0
- Human intervention count: 0
- Merge recommendation: yes / no
