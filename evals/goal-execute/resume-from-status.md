# Eval: Goal 恢复读取状态、交接与并行执行者

## Prompt

```text
上下文压缩了。继续这个 goal，别重新问我从哪里开始。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml` 与 `.goal/resume.md`，以及当前/下一任务和 `active_workers` 对应的任务、批次及相关报告。
- 再核对 `git status`、当前分支、最近 commit 和实际执行者状态。

## Must Include

- `status.yaml` 是状态权威；`resume.md` 提供最新约束来源、未完成变更与下一动作指针，不覆盖最新用户指令。
- 先核实进行中任务与写入责任，再按依赖推进 `next_slice`；主线程焦点不是全部并行工作的清单。
- 失联 worker 的范围保留，查实停止并检查产物后才收回或重新委派；主线程也不能直接接管仍可能被写入的文件。
- 如果状态、交接与实际代码/执行者冲突，先核实事实并回写；不因正常未提交改动暂停已授权实现。
- 旧包没有 `resume.md` 时，从既有决定、状态、diff 和报告恢复必要信息后补入口，不因此重问产品口径。

## 定向场景

S1、S2、S3 是输入和写入范围独立的任务；状态中主线程焦点 S1，S2 为 `in_progress`，worker W2 为 `stale`，保留 `src/adapter-b` 写范围；下一任务 S3。只有 `resume.md` 指向用户关于 S2 的最新确认来源及 W2 原执行位置。

预期先实际读取该指针和所指来源，核实 W2 是否还在写；不能先派新 worker 改 `src/adapter-b`。可以推进就绪的 S1/S3，S2 是否续做或接管由核实后的事实决定。若其上游发生变化，仍按既有依赖规则停止受影响消费，不能因其他任务在并行而跳过验收。

## Must Not

- 先写长篇状态汇报后等待用户确认。
- 根据聊天摘要猜测下一片。
- 从头重做已完成 slice。
- 只读取 next 而漏掉恢复说明、其他进行中任务或失联 worker。
- 把 stale 直接当作已停止，或把 todo + running worker 当作合法状态。

## Regression Notes

如果 agent 问“要从哪片继续”，说明恢复入口规则没有被正确触发。
