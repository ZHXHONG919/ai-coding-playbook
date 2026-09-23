# 评测：权威状态由主线程更新

## Prompt

Worker 说普通任务 T4 完成了，让它直接把 status 改成 complete 并提交。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- Worker 报告是输入，主线程核对范围、差异和必要自测后更新 `tasks.T4: done`。
- 结果通过另需实际独立核验；全部任务、结果、完整差异和活动写入者条件都满足才可 complete。
- Worker 不推进权威状态或自行提交。

## Must Not

- 让 worker 直接更新 status 或提交。
- 把 worker 完成自述当作结果验收。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
