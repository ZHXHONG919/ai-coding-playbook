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

## 证据门禁

| 项目 | 结果 | 证据 |
| --- | --- | --- |
| 证据等级 | E0 / E1 / E2 / E3 | |
| 期望基线 | 需求 / 界面流程 / 原型 / 现有页面 / 接口契约 / 无 | |
| 证据门禁 | 无需视觉证据 / 接口数据 / 冒烟 / 实现截图 / 修改前后 / 原型对比 / 角色对比 / 多端一致性 | |
| 关键角色、状态和端 | Passed / Blocking / Skipped | |
| 与任务验收逐条映射 | Passed / Blocking | |
| 共享证据说明 | 无 / 关联任务 ID | |
| 界面采集尝试与降级 | 定位方式、尝试次数、降级原因或不适用 | |

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
