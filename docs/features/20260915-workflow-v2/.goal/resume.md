# 恢复入口

2026-09-17：D10 实现已完成，状态与证据见 status.yaml、validation/parallel.md、cr/parallel.md。用户已明确授权发布，随后明确顺序为：提交 PR → merge main → 本地切到 main → 发布 Codex/Cursor。该最新指令替代设计期“暂不应用”的发布限制。

发布执行情况以远端 PR、实际 main HEAD 和安装链接为准，不能从候选完成状态推断已经安装。原始核验与候选快照保留为历史证据；来源在候选工作树，不能冒充 main 中重新生成的快照。新业务需求尚未开始。
