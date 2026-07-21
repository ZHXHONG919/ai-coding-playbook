# TODO Ledger

> 目标：记录 CR、实现、验证中发现的局部待确认、需求优化、交互建议、契约优化和技术债。默认不阻塞 Goal 连续推进，开发完成或阶段 checkpoint 时集中和人对齐。

## Open Items

No open TODO items.

## Ledger

| TODO ID | Source Slice | Source | Type | Current Impact | Latest Alignment Point | Suggested Handling | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TD-R01-001 | R01 | CR / implementation / validation / user feedback | requirement-question / UX-improvement / contract-improvement / tech-debt | non-blocking / blocking reason | R99 / goal-end / next kickoff | follow-up slice / backlog / drop | open / closed / promoted-to-blocker | |

## Blocking Promotion Rules

Promote a TODO to `blocking_delta` only when:

- Current P0/P1 acceptance cannot be judged or no longer holds.
- Continuing would create wrong data, wrong permissions, or wrong state.
- A later slice directly depends on the unresolved contract and it cannot be isolated by mock, adapter, or feature flag.
- The user explicitly asks to stop and confirm before continuing.

## Rules

- Local pending questions and improvement ideas do not block the next slice by default.
- CR must fix current-scope blockers, but should route non-blocking demand changes here.
- Final Goal output must summarize open TODO items for human alignment.
