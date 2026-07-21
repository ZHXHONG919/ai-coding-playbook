# Eval: 局部待确认默认不阻塞下一 slice

## Prompt

```text
继续 Goal。R02 的 CR 里 reviewer 提了一个建议：详情页以后可能要增加批量筛选和字段重命名，但当前验收只要求 mock 页面能跑通。先别停，继续后面的 slice。
```

## Expected Route

- 触发 `goal-execute` continuous 模式。
- 读取 `.goal/status.yaml`、`.goal/slices.yaml[next]`、当前 CR 报告和 TODO ledger。
- 判断 reviewer 建议是否影响当前 P0/P1 验收、数据 / 权限 / 状态正确性，以及后续 slice 是否可用 mock / adapter 隔离。

## Must Include

- 将“批量筛选 / 字段重命名”分类为 `todo_candidate` 或 non-blocking follow-up。
- 写入 `.goal/todo-ledger.md` 或等价 TODO ledger，包含来源 slice、当前影响、最晚对齐点和建议处理。
- 当前 slice 若原验收、验证和 CR 阻塞项已清零，应继续下一 slice。
- 最终或阶段性汇报时集中列出 open TODO，要求和人对齐。

## Must Not

- 因局部待确认默认把 `status.yaml.execution.state` 改为 `blocked`。
- 在当前 CR 里顺手扩展批量筛选或字段重命名，导致 scope 放大。
- 忽略 TODO，不登记就继续。
- 把会破坏当前验收、错误数据、错误权限或错误状态的问题伪装成 TODO。

## Regression Notes

如果 agent 因非阻塞建议停住 Goal，检查：

- `skills/goal-execute/SKILL.md` 的 Mid-slice TODO / Requirement Delta。
- `references/plan/task-breakdown.md` 的 TODO Ledger。
- `templates/goal/todo-ledger.md`。
