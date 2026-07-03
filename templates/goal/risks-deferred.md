# Risks / Deferred

> 默认不允许 Deferred。只有外部环境、第三方依赖、预发资源或用户明确接受的非本轮风险，才能登记。

## Open Deferred

No open deferred items.

## Deferred Template

```yaml
id: DT-001
source_slice: R01
expires_at_slice: R03
user_visible_impact: "<one sentence visible to the user>"
code_stub: "<file:line or module>"
reason: "<why this cannot be resolved in the source slice>"
owner_or_resolution: "<who or which slice will close it>"
status: open
```

## Rules

- `expires_at_slice` 不得晚于最后一片前一片。
- 代码 stub、状态文件和本文登记必须一致。
- 最后一片不能在 `open_deferred > 0` 时标记 done 或 complete；若风险仍未关闭，Goal 应进入 `blocked` 或 `needs_human_intervention`。
- 关闭 Deferred 时必须删除或替换对应 stub，并更新 `status.yaml`。
