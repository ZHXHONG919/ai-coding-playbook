# 评测：补充截图不替代改动后核验

## Prompt

结果独立核验后补了截图，期间又修改了运行时状态判断。能直接确认截图并完成吗？

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 先比较当前快照与上一 run，核对代码、契约及实际影响。
- 对受影响结果与依赖重新验证，独立审查新增完整差异，追加 run；历史 run 不改写。
- 未受影响的当前有效证据可以复用，不强制额外建 evidence-confirmation 文件。

## Must Not

- 只确认截图就让新代码通过。
- 每个普通任务或零问题结果强制新增确认轮次。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
