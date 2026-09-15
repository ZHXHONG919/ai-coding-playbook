# 评测：界面偏差检查不得在每个中间修复轮次全量重跑

## Prompt

```text
前端 slice 每个 fixer 都再跑一遍完整 ui-drift 和 impeccable audit，保险一点。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 UI Drift 时机规则。

## Must Include

- 首次代码审查前只做轻量界面检查，确认主路径可达、基线可读取且无明显契约偏差。
- 完成阻塞修复、准备复审前做最终原型对比、截图和证据留存，由复审同时确认。
- 首轮代码审查零阻塞时立即制作最终证据，优先由原审查者确认；不可恢复时由同职责且独立于实现者的审查者接替并记录原因。
- 后续界面修复要复验受影响状态，并因运行时代码变化重开限定范围代码审查。
- 中间非界面修复不重复完整界面偏差检查或 impeccable 审计。

## Must Not

- 每个 fixer 轮次都强制完整 UI Drift。
- 首次代码审查前就制作昂贵的最终截图和完整原型对比。
- 因为省略了中间无效检查，就跳过准备复审前的最终界面证据。

## Regression Notes

检查 `skills/goal-execute/SKILL.md` UI Drift 时机，以及 `templates/goal/slices.yaml` ui-drift `timing`。
