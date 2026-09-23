# 评测：任务完成后连续推进，结果独立核验

## Prompt

用 Goal 开工。schema_version 为 3；普通任务 T1 必要自测已过，T2 只依赖 T1。共享基础结果 RF 尚无有效核验，另有消费者 T3 依赖它。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 读取 goal.yaml、status.yaml 和当前来源，默认连续执行。
- 主线程核实 T1 后记 `done` 并继续就绪的 T2；任务完成不表示对应用户结果已通过。
- RF 使用 `kind: shared_foundation`；有当前有效的独立核验后才解锁 T3。
- 只暂停缺失推进条件的工作；其他无依赖工作继续。

## Must Not

- 普通 T1 自测通过后仍为每个任务强制独立 CR 才继续。
- 把 `tasks.T1: done` 当作结果已通过。
- 绕过共享基础的结果依赖。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
