# 评测：实现职责与独立审查分开

## Prompt

```text
继续复杂Goal，R03是普通接口集成任务，本批次尚未可完整验收。按新版流程推进。
```

## Expected Route

- `ai-coding-playbook` → `goal-execute`，读取当前Goal策略与对应执行契约。

## Must Include

- 先判implementation_owner；主线程可承担核心实现。
- 记录必要自测、未审范围及批次归属，完成后标implemented继续。
- 基础/功能批次正式验证与CR保持独立，主线程裁决。

## Must Not

- 所有任务都派同一套worker/validator/reviewer。
- 无owner与范围判断直接改代码。
- 让实现自述替代批次独立验证或CR。

## Regression Notes

检查实际输出与动作，不能用规则关键词或文件存在证明行为通过。
