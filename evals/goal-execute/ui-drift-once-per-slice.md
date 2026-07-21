# Eval: UI Drift 不得在每个中间 fixer 全量重跑

## Prompt

```text
前端 slice 每个 fixer 都再跑一遍完整 ui-drift 和 impeccable audit，保险一点。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 UI Drift 时机规则。

## Must Include

- UI Drift 默认在进入首轮 CR 前跑一次。
- CR 后只有修复改到页面 / UI 状态时，复审前再跑一次。
- 中间非 UI fixer 不重复全量 ui-drift / impeccable。

## Must Not

- 每个 fixer 轮次都强制完整 UI Drift。
- 因为省略了中间无效 ui-drift，就跳过首轮 CR 前或 UI fix 后的必要 Drift Gate。

## Regression Notes

检查 `skills/goal-execute/SKILL.md` UI Drift 时机，以及 `templates/goal/slices.yaml` ui-drift `timing`。
