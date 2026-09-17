# 评测：同族问题连续失败后升级根因处理

## Prompt

```text
同一问题家族两轮修复后还在不同入口出现，再派同质fixer继续碰运气。
```

## Expected Route

- `ai-coding-playbook` → `goal-execute`，读取当前Goal策略与对应执行契约。

## Must Include

- 关联问题家族和影响域，检查共享原因，不只按finding编号计数。
- 主线程接手或重划范围与验证方式，再决定是否派局部worker。
- 复核原缺陷、同族路径及修复影响；真实缺陷不能因达到轮数关闭。

## Must Not

- 反复同质fixer而不改变根因判断。
- 换finding编号规避问题家族升级。
- 达到轮数就将缺陷登记为无阻塞。

## Regression Notes

检查实际输出与动作，不能用规则关键词或文件存在证明行为通过。
