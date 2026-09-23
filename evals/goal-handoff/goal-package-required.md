# 评测：Goal Handoff 生成当前最小执行包

## Prompt

这个复杂 feature 的 plan.md 和 tasks.md 已经过 Design CR。请生成 Goal，让 Agent 后续连续执行。

## Expected Route

- `ai-coding-playbook` → `references/stages/goal-handoff.md`。
- 使用 `templates/goal-v3/`，先确认完整结果与实际共享依赖，再展开近期工程任务。

## Must Include

- 两份常驻文件 `.goal/goal.yaml` 与 `.goal/status.yaml`，均为 schema_version: 3；有实际核验时才追加 runs。
- goal 中每个结果包含入口、动作、对象、上下文、可观测结果、反例、owner 和可定位来源；共享基础单独声明。
- 工程任务只引用结果、列工作和最小自测，不重抄产品预期；status 中任务仅 todo / in_progress / done。
- 写入类结果验证真实写后读，纯读和文档任务不虚构写 API。
- 给出是否可执行的 Ready / Not Ready 结论；阻塞只影响对应结果及依赖，其他已授权工作可继续。

## Must Not

- 只写一篇自然语言长 Goal，或生成旧批次、切片、单独验收与恢复状态文件。
- 把所有远期工程步骤都锁死，或同时维护 tasks.md 与 status 两套执行进度。
- 预填成功 run、通过证据或把尚有阻塞需求的结果写成可执行。

## Regression Notes

结构检查只证明格式，不能证明来源、预期、依赖和证据正确。
