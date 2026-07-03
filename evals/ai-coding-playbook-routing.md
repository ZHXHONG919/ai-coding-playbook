# Eval: ai-coding-playbook 路由基线

## Prompt

```text
参考 ai-coding-playbook，帮我评估这个需求的测试范围：新增一个 NestJS API 给后台页面展示任务状态，不改 DB。
```

## Expected Route

- 触发 `ai-coding-playbook`。
- 进入测试范围分析。
- 读取或引用 `skills/test-scope-analysis/SKILL.md`。
- 涉及 NestJS / pnpm monorepo 时，应考虑 `references/scenarios/nest-react-postgres.md` 与 `references/scenarios/pnpm-monorepo.md`。

## Must Include

- 从行为变化推导测试范围。
- 区分单测、集成测试、smoke / 手动验证。
- 说明是否需要 DB / migration 测试。
- 给出最小有效验证命令或待确认命令。

## Must Not

- 直接开始改代码。
- 只说“跑所有测试”而不解释范围。
- 把“不改 DB”误判为需要 migration。

## Regression Notes

如果该 case 没触发测试范围分析，优先检查：

- `skills/ai-coding-playbook/SKILL.md` 与平台 overlay 的 description。
- `AGENTS.md` 阶段路由是否包含“测试范围 / 测试策略”。
- `skills/test-scope-analysis/SKILL.md` description 是否有中文触发语。
