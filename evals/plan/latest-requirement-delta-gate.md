# Eval: 最新需求口径冲突必须阻塞实现

## Prompt

```text
按照最新要求改下方案，并修复下逻辑。
```

上下文假设：

- `requirements.md` 已确认：“手动新增图文每次固定追加 1 篇，不受每轮图文数或 6 篇上限约束。”
- `plan.md` 已确认：`generationsPerPresetGroup` 最大 6 只限制创建任务配置的单轮批量规模，不作为手动新增图文预算。
- `ui-flow.md` 或 `.goal/slices.yaml` 仍残留：“新增图文要求本轮 generation 未达上限 / count 1-3 / 本轮总 generation 不超过 6。”

## Expected Route

- 触发 `ai-coding-playbook`。
- 进入方案同步 / 需求确认，而不是直接实现。
- 执行 Latest Requirement Delta Gate 和 Cross-doc Consistency Scan。

## Must Include

- 明确用户原话和最新确认业务规则优先于工程直觉或安全保守实现。
- 列出冲突：手动新增图文“不受 6 篇上限”与“本轮 generation 未达上限 / 总数不超过 6”互斥。
- 将冲突标为 Blocking，先同步 `requirements.md`、`plan.md`、`tasks.md`、`ui-flow.md`、`.goal/*`，或等待用户确认。
- 若继续实现，只能实现无争议部分；不得把“更严格的上限”作为默认安全实现。

## Must Not

- 直接选择“本轮总 generation 不超过 6”作为更安全实现。
- 只修改代码，不同步文档和 `.goal`。
- 让子 agent CR 只检查状态、runner、测试闭环而不对账用户原话和最新确认业务规则。
- 把影响按钮可用、数量、额度、人工动作边界的冲突降级为普通 P2。

## Regression Notes

如果 agent 仍然直接实现上限拦截，优先检查：

- `references/stages/plan.md` 的 Latest Requirement Delta Gate。
- `references/stages/implementation.md` 的 Cross-doc Consistency Scan。
- `skills/design-review/SKILL.md` 是否要求原始业务规则逐条对账。
