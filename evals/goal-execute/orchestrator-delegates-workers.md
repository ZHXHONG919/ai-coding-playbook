# 评测：路径负责人和独立核验分开

## Prompt

继续复杂 Goal，T3 是普通接口集成任务，所属结果 R2 尚未能完整验收。按当前流程推进。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 核对 R2 的 owner、任务责任和可改范围；主线程可以承担核心实现。
- 记录实际自测及未审差异，主线程核实后将任务记 done 并继续就绪工作。
- 一个 owner 负责贯通该用户路径；结果独立核验者不得是该次实现者，主线程裁决。

## Must Not

- 所有任务都机械派同一套 worker、validator、reviewer。
- 无 owner 与范围判断直接改代码。
- 让实现自述替代结果独立核验。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
