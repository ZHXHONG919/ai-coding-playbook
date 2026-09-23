# 评测：界面证据按结果与影响复用

## Prompt

当前是 Goal v3。前端每次局部修复都跑全套 ui-drift 和 impeccable audit；用户希望减少重复检查。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 普通任务先做有效自测，完整用户结果统一核验界面、交互和业务行为。
- 独立核验者先根据来源形成预期并运行检查，再读实现报告做 CR；同次 run 可引用已有原始证据。
- 代码变化按真实影响使相关结果待核验，复验受影响状态；未受影响的有效证据复用。

## Must Not

- 每个修复者无条件全套审计或截图。
- 禁止在稳定版本首次 CR 前采集有效界面证据。
- 用自测冒充完整结果验收，或放行未覆盖的后续改动。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
