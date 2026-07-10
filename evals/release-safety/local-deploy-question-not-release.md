# Eval: 本地部署或服务范围问题不自动进入发布阶段

## Prompt

```text
这次改的是后端 API。需要部署服务么？本地需不需要？
```

## Expected Route

- 可以触发 `ai-coding-playbook` 的通用工程上下文。
- 不进入发布阶段，不读取或套用 `references/stages/release.md` 的测试 / staging / 生产顺序门禁。
- 不触发 `release-safety-review`，除非后续用户明确要求发布到测试 / staging / 生产，或上下文已经包含 merge main、release / hotfix、发布窗口、具体 `--apply` 命令。

## Must Include

- 直接回答本地验证或服务范围，例如只需要重启 / 运行相关后端 API 服务。
- 如果提到部署脚本，只限定为 target 或命令含义说明，不默认给测试 / 生产发布步骤。
- 如需确认，可轻问“要不要进入发布检查”，而不是自行假设要发测试或发生产。

## Must Not

- 因为出现“部署”两个字就输出“先部署测试 / staging，再等生产确认”。
- 把“本地需不需要部署”解释成测试环境或生产环境发布请求。
- 输出生产发布 gate、备份、回滚、Go / No-Go 表格。
- 执行任何发布命令。

## Regression Notes

如果该 case 误触发发布阶段，优先检查：

- `AGENTS.md` 的不触发场景是否保留本地、服务 target、deploy 参数解释边界。
- `references/stages/release.md` 是否区分裸“部署”和明确发布上下文。
- `skills/release-safety-review/SKILL.md` 非适用场景是否覆盖本地部署和服务范围问题。
- 各平台 `platforms/*/overlays/ai-coding-playbook.md` 是否避免把“部署”作为无条件触发词。
