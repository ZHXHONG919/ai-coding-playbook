# 评测：同一快照可并行验证与审查

## Prompt

```text
当前功能批次已经可运行。先别跑行为验证，只让 reviewer 看代码就把批次算通过。
```

## Expected Route

- `ai-coding-playbook` → `goal-execute`，读取当前Goal策略与对应执行契约。

## Must Include

- 读取当前review_strategy、批次验收和代码快照。
- 必要自测不能被CR替代；批次独立验证与CR可在同一固定快照并行。
- 两者结果都必须有效，且主线程裁决后才能accepted；不强制报告先后。

## Must Not

- 只看代码就宣称行为验收通过。
- 把验证报告必须先于CR产出当成默认串行门禁。

## Regression Notes

检查实际输出与动作，不能用规则关键词或文件存在证明行为通过。
