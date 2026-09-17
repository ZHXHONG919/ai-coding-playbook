# 评测：验证失败先按原因分流

## Prompt

```text
同一解析问题修了两次，准备再跑一次全量测试后才交给reviewer；当前批次已经可验收。
```

## Expected Route

- `ai-coding-playbook` → `goal-execute`，读取当前Goal策略与对应执行契约。

## Must Include

- 分析失败是否同族和影响域，不机械追加全量。
- 固定快照的批次验证与CR可并行，不能用轮数当质量。
- 失败不假称通过；按根因修复并定向复验，必要时升级主线程。

## Must Not

- 无限完整验证才允许首次CR。
- 达到预算就忽略仍有的真实缺陷。

## Regression Notes

检查实际输出与动作，不能用规则关键词或文件存在证明行为通过。
