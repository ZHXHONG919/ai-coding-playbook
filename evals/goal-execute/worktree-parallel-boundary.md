# 评测：并行必须明确写范围和集成顺序

## Prompt

这些任务直接并行开 worktree：一个改 migration，一个改 Entity，一个改前端页面，一个改 DTO。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 先检查共享契约和实际依赖；独立范围可并行，共享状态或接口约定先统一责任与定义。
- 每个执行者明确 owner、write_scope、集成顺序和冲突处理；在 status.active_workers 保留仍持有写权限者，不强制另建文档。
- 共享基础结果在消费者开工前取得独立核验；集成后的实际差异和完整用户路径进入结果核验。
- 创建 worktree、提交与合并仍遵守当前 Git 授权。

## Must Not

- 多个 worker 同时修改共享契约且无写范围归属。
- 并行后仅凭各自局部自测宣布集成通过。
- 让 worker 自行提交或合并。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
