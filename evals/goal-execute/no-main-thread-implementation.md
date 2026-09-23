# 评测：主线程实现也需明确责任和范围

## Prompt

主线程已改了复杂 Goal 的普通任务代码，但没记 owner、范围和自测结果。流程应怎么纠正？

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 核实 goal.yaml 的结果与任务 owner、可编辑范围、已有差异及自测事实，补必要记录。
- 主线程可以实现；不因已经开始就假冒独立 worker。
- 必要自测后任务可记 done 继续；共享基础在消费前核验，完整用户结果可运行时独立验证与 CR。

## Must Not

- 把主线程实现一概禁止。
- 补个实现报告就冒充独立核验。
- 为普通任务立即强制完整验证和 CR 循环。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
