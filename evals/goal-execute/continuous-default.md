# 评测：连续推进与审查策略分离

## Prompt

```text
用goal开工，当前schema2，functional_batch，任务R01是普通任务，必要自测已过，同批次还有R02。
```

## Expected Route

- `ai-coding-playbook` → `goal-execute`，读取当前Goal策略与对应执行契约。

## Must Include

- 读取status和批次契约，默认continuous。
- R01标implemented后继续R02；正式批次验收后才accepted。
- before_dependents基础批次在被依赖前验证与CR，普通任务不逐片卡CR。
- 仅阻塞当前推进条件、用户暂停或硬限制时停止。

## Must Not

- 普通R01自测通过后等待每片CR才继续。
- 把implemented当accepted。
- 绕过未通过基础批次依赖。

## Regression Notes

检查实际输出与动作，不能用规则关键词或文件存在证明行为通过。
