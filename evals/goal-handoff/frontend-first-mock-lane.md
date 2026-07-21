# Eval: 前端全栈 Goal 必须继承 Frontend-first Mock Lane

## Prompt

```text
目标项目 lume-tuber，这个需求有一个后台页面和几个 API。方案已经 Ready，帮我拆 tasks 并生成 Goal 包，按功能点切片就行：一个 slice 做内容池，一个 slice 做发布，一个 slice 做审核。
```

## Expected Route

- 触发 `ai-coding-playbook` 的任务拆解 / Goal Handoff。
- 读取 `references/plan/task-breakdown.md` 和 `references/stages/goal-handoff.md`。
- 检查是否涉及前端项目 + API 交互。

## Must Include

- `tasks.md` 必须先按 Frontend-first Mock Lane 拆：
  `CONTRACT → FE_MOCK_LOOP → SERVER_CAPABILITY → MOCK_REPLACEMENT → INTEGRATION / QA`。
- Goal Handoff 只能继承 `tasks.md` 的 lane 和依赖图，不能重新按独立功能点发明 slice 顺序。
- `FE_MOCK_LOOP` 必须包含页面交互、ViewModel、接口 mock / 接口壳、mock 数据、浏览器 smoke、UI Drift / impeccable 记录。
- 每个 mock / pending API 必须写入 `.goal/mock-ledger.md`，并有清理 slice。
- `slices.yaml` 中每个 slice 必须有 `lane` 或等价 task type，可追溯到 `tasks.md`。

## Must Not

- 直接按“内容池 / 发布 / 审核”等独立功能点把前端、后端、DB、service 混到同一批 slice。
- 跳过 `FE_MOCK_LOOP`，先做后端 DB / service。
- 在 Goal Handoff 阶段覆盖已经确认的 `tasks.md` 任务顺序。

## Regression Notes

如果 agent 仍按功能点拆 slice，优先检查：

- `references/plan/task-breakdown.md` 的 Frontend-first Mock Lane。
- `references/stages/goal-handoff.md` 的 Goal Gate。
- `templates/goal/slices.yaml` 的 `lane` 字段。
