# 评测：恢复读取当前约束与所有写入者

## Prompt

上下文压缩了。继续这个 Goal，别重新问我从哪里开始。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 读取 goal.yaml、status.yaml、当前结果来源和 runs，运行当前检查器，再核实 Git 差异及执行者事实。
- status 的 `next_action`、`constraints`、`active_workers` 和 `open_gaps` 提供恢复索引；最新用户指令优先。
- 先核实进行中任务与写入责任，再按结果和任务依赖推进；主线程焦点不是全部并行工作的清单。
- 失联 worker 的范围保留，确认停止并检查产物后才收回或重新委派。
- 状态与实际事实冲突时先核实并回写；未审差异要判断影响，不能把历史通过套到当前代码。

## Must Not

- 只读下一动作而漏掉当前约束、其他进行中任务或失联 worker。
- 把 stale 直接当作已经停止，或重新派人写仍被持有的范围。
- 从头重做所有已完成任务，或仅凭聊天摘要猜下一动作。

## 定向场景

T1、T2、T3 的写入范围独立。T2 为 in_progress，worker W2 为 stale 且仍持有 src/adapter-b；next_action 指向 T3。constraints 指向用户关于 T2 的最新决定和 W2 原执行位置。先读取这些来源并核实 W2；T1/T3 若依赖就绪可推进，T2 的接管由核实后的事实决定。共享基础证据过期时，受影响消费者不能因并行而绕过依赖。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
