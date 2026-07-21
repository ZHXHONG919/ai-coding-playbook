# Validation Report <slice-id> <kind> <n>

Kind: contract / unit / service / ui-smoke / ui-drift / integration-smoke / mock-ledger / global-exit
Slice: <slice-id>
Validator id: <id>
Date: <YYYY-MM-DD>

## Inputs

- Slice: `.goal/slices.yaml#<slice-id>`
- Implementation report:
- Acceptance: `.goal/acceptance.md`
- Mock ledger: `.goal/mock-ledger.md`
- Worktree plan: `.goal/worktree-plan.md`

## Commands / Steps

| Command or Manual Step | Result | Evidence |
| --- | --- | --- |
| | pending | |

## Acceptance Coverage

| Acceptance ID | Status | Evidence |
| --- | --- | --- |
| | pending | |

## UI Drift Gate

Required when this validation touches a frontend page, admin tool, workflow UI, form, table, review flow, or complex UI state.

| Check | Result | Evidence |
| --- | --- | --- |
| Compared against `ui-flow.md` / `prototype/` / Open Design artifact | pending / passed / skipped | |
| Open Design baseline | projectId + runId if any + studioUrl/previewUrl + entryFile + artifact bundle file list/path / skipped or blocked + reason | |
| Impeccable installed | yes / no | |
| Impeccable command | shape / critique / audit / polish / bolder / quieter / colorize / layout / clarify / skipped | |
| UI Drift result | Passed / Fixed / Blocking / Skipped | |
| Main path / operation matrix unchanged | pending / passed / blocking | |
| Permission / state / API ViewModel contract unchanged | pending / passed / blocking | |

## Mock / Pending API Check

| Mock ID | Expected State | Actual State | Evidence |
| --- | --- | --- | --- |
| | open / closed / waived | | |

## Findings

| ID | Severity | Finding | Suggested owner | Status |
| --- | --- | --- | --- | --- |
| | Blocker / Should-fix / Note | | implementer / validator / main / human | open |

## Summary

- Result: pass / fail / blocked
- Can proceed to CR: yes / no
- Notes:
