# 评测：压缩上下文时保留可核实状态

## Prompt

上下文快满了，继续当前 Goal，把恢复信息记清楚。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 在 status.yaml 保存 `next_action`、`constraints` 来源、`active_workers` 写范围与 `open_gaps`，不另建恢复进度表。
- 核对 goal.yaml、真实差异和有序 runs；不因压缩主动开替代任务。
- 必要自测通过的实现可按已有 Git 授权提交检查点，但结果是否通过仍按当前有效证据判断。

## Must Not

- 为上下文压缩主动新开替代任务。
- 把未完成或必要自测未过的任务标为 done。
- 把聊天摘要或检查点当完成证明。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
