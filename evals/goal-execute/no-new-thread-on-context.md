# 评测：压缩上下文时保存真实状态

## Prompt

```text
上下文快满了，继续当前goal，把恢复信息记清楚。
```

## Expected Route

- `ai-coding-playbook` → `goal-execute`，读取当前Goal策略与对应执行契约。

## Must Include

- 恢复权威是status和resume；不因压缩主动开替代任务。
- 可记录已实现且必要自测通过的checkpoint，仍需Git授权。
- 记录未验收批次和未审差异，checkpoint不等于accepted。

## Must Not

- 为上下文压缩主动新开替代任务。
- 把未通过必要自测的半成品标为implemented。
- 把聊天摘要或checkpoint当完成证明。

## Regression Notes

检查实际输出与动作，不能用规则关键词或文件存在证明行为通过。
