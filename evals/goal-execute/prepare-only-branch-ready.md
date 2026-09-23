# 评测：询问可开工状态只做准备检查

## Prompt

当前分支可以进入开发了么？项目已有 v3 Goal 包，当前为 feature 分支，可能有未跟踪的需求文档。

## Expected Route

`ai-coding-playbook` 的 Git / Goal 准备检查；读取 `references/stages/implementation.md` 和 `references/stages/goal-handoff.md`。

## Must Include

- 只核对项目规则、分支、实际差异、goal/status、结果来源及工具依赖准备情况，给 Ready / Not Ready 判断。
- 说明具体缺口或下一动作；新需求文档未提交或未配置 upstream 本身不自动成为实现阻塞，按项目规则判断。
- 如果已就绪，只指出下一项就绪任务，不把询问当成实施授权。

## Must Not

- 修改业务代码、派发 worker 或自动创建 App Goal。
- 把“可以开发吗”理解成“开始实现”。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
