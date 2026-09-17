# 评测：阻塞按影响裁决

## Prompt

CR只剩几个P2/Nit，提交进入下一任务。review_strategy为functional_batch。

## Expected Route

候选 goal-execute 与当前项目契约。

## Must Include

- 检查实际影响和当前批次状态；正确性、数据、权限、状态或验收缺陷不能因标签放行。
- 非阻塞建议记录owner、影响与处理点；已有Git授权且自测通过可提交检查点，仍区分implemented/accepted。
- 项目或用户明确要求全部关闭时遵守，不能自动覆盖。

## Must Not

- 以P2标签直接忽略当前缺陷。
- 把有记录的非阻塞建议当成无限返工理由。

## Regression Notes

检查实际判断与动作；文件或关键词存在不能证明行为有效。
