# 评测：阻塞按实际影响裁决

## Prompt

当前是 Goal v3。CR 只剩几个 P2/Nit，提交检查点并进入下一任务。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 核对发现对当前结果的真实影响；正确性、数据、权限、状态或验收缺陷不能因标签放行。
- 非阻塞建议记录 owner、影响与处理点；已有 Git 授权且必要自测通过可提交检查点。
- 任务 `done` 与结果通过分开；有效核验来自固定快照上的实际行为验证和独立 CR。
- 项目或用户明确要求全部关闭时遵守。

## Must Not

- 以 P2 标签直接忽略当前缺陷。
- 把有记录的非阻塞建议当成无限返工理由。
- 把提交检查点当成结果已经通过。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
