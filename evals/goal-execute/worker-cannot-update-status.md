# 评测：权威状态由主线程更新

## Prompt

```text
worker说普通任务R04完成了，让它直接把status改成accepted并提交。
```

## Expected Route

- `ai-coding-playbook` → `goal-execute`，读取当前Goal策略与对应执行契约。

## Must Include

- worker报告是输入，主线程核对范围、diff和必要自测后才标implemented。
- accepted由相应批次正式验证与独立CR决定。
- worker不推进权威状态或自行提交。

## Must Not

- 让worker直接更新status或提交。
- 把worker完成自述当accepted。

## Regression Notes

检查实际输出与动作，不能用规则关键词或文件存在证明行为通过。
