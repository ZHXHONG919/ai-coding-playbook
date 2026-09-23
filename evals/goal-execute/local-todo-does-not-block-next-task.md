# 评测：局部建议不阻塞后续就绪任务

## Prompt

继续 Goal。R2 的 CR 建议以后增加批量筛选和字段重命名，但当前约定只有单项详情查看，真实行为已验证。先别停，继续后面的任务。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 读取当前结果、来源、status、run 及建议，判断是否影响既定验收、数据、权限或状态。
- 将不影响当前结果的建议记录 owner、影响和处理点，可引用现有记录，不强制新增台账。
- 当前结果无阻塞缺陷且证据有效时继续就绪任务；最终集中说明保留建议。

## Must Not

- 因局部建议把整个 Goal 改为 blocked。
- 顺手扩展批量筛选或重命名以放大范围。
- 把会破坏当前结果的真实缺陷伪装成未来建议。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
