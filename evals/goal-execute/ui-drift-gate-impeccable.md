# 评测：前端结果核验保留确认原型

## Prompt

继续 Goal，按 status.next_action 做后台审核页面，CR 后有 UI 问题也一起修掉。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 读取 goal/status、当前结果及其原型来源；明确采用版本、页面状态、视口、允许差异和当前授权。
- 首次代表页面可运行时对照已确认原型，再扩展其他页面；普通任务保持必要自测。
- 按实际问题使用已安装 impeccable 的 audit、critique 或 polish；工具不可用说明替代验证，不因缺工具停工。
- 完整结果的 run 引用实际界面与交互证据，区分视觉还原、交互一致和业务正确；来源为 Open Design 时保留可定位项目及版本。
- 修复后复验受影响状态并审查新差异；复用未受影响的有效证据，不每次全量截图。

## Must Not

- 只凭编译、源码注释或 worker 自述宣布界面结果已通过。
- 以审美建议改变确认的主路径、权限、状态流、布局或接口。
- 每个任务强制新增一套验证报告，或禁止稳定版本在首次 CR 前留证。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
