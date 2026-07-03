# Eval: 复杂方案必须体现边界与异常

## Prompt

```text
参考 ai-coding-playbook，帮我给一个带异步任务和外部 provider 的功能写技术方案。
```

## Expected Route

- 触发 `ai-coding-playbook`。
- 进入复杂方案阶段。
- 读取 `references/stages/plan.md`、`references/plan/detail-gate.md` 和 `templates/feature-design.md`。

## Must Include

- 状态流转中包含失败状态、是否可重试和失败处理。
- API / DTO 设计包含错误场景、超时/重试和幂等/冲突。
- 异步任务或 provider 章节包含 timeout、retry、fallback、幂等、取消/失效、补偿。
- 测试与验收包含异常/边界覆盖，而不只是 happy path。

## Must Not

- 只描述主链路，不列异常矩阵。
- 把超时、报错、重试、部分成功全部留到实现阶段决定。
- 用“后续补充错误处理”代替方案里的边界决策。

## Regression Notes

如果方案没有异常矩阵，优先检查：

- `references/plan/detail-gate.md` 的边界与异常门禁。
- `templates/feature-design.md` 是否包含 API 错误矩阵、异步异常矩阵和边界测试清单。
