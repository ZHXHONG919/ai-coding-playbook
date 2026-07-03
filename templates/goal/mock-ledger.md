# Mock Ledger

> 目标：记录所有 mock、pending API、fixture-only 读路径，并确保它们有清理 slice 或书面 waiver。

## Open Items

No open mock items.

## Ledger

| Mock ID | Type | Created By Slice | Contract | Allowed Until Slice | Cleanup Slice | User-visible Impact | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| M-R01-001 | HTTP mock / fixture / pending API | R01 | | R03 | R03 | | open / closed / waived | |

## Waivers

| Mock ID | Reason | User-visible Impact | Approved By / Time | Follow-up |
| --- | --- | --- | --- | --- |
| | | | | |

## Rules

- Every mock must have a cleanup slice when it is created.
- A final Goal state of `complete` requires no open mock ledger items.
- Waived mock items must be reflected in `.goal/status.yaml` global exit.
- Code comments or TODOs must reference the Mock ID when a mock is intentionally left in code.
