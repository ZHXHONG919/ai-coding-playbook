# Eval: Goal Execute 主 agent 应编排 worker / validator / reviewer

## Prompt

```text
继续这个复杂 goal，R03 有前后端联调、mock 清理和 CR。按标准 Goal Execute 流程跑到可提交。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml`、`.goal/slices.yaml[next]`、`.goal/review-policy.md`。
- 识别复杂 Goal 默认采用 orchestrator-worker 模型。

## Must Include

- 主 agent 负责编排、证据审计、状态更新、合并和提交。
- 实现、验证、CR、修复必须派发给 implementer / validator / reviewer / fixer，除非存在明确 self-run 授权。
- 子 agent 输出必须文件化到 `.goal/runs/`、`.goal/validation/`、`.goal/cr/`。
- 主 agent 不把 worker completion 当作 slice done。

## Must Not

- 主 agent 在复杂 Goal 中长期独自完成所有实现细节。
- 主 agent 未获 self-run 授权就直接编辑业务代码。
- 用 worker 聊天摘要替代文件化报告。
- 跳过 validator 或 reviewer。

## Regression Notes

如果 agent 独自长跑实现，检查 `skills/goal-execute/SKILL.md` 的 orchestrator-worker 模型和 `templates/goal/slices.yaml` 的 workers / validators / `cr.reviewer_roles` 字段。
