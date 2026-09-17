# 评测：界面证据按批次与影响复用

## Prompt

前端普通任务每次fixer都跑全套ui-drift和impeccable audit，保险一点。当前策略functional_batch，用户希望减少重复检查。

## Expected Route

按当前Goal与review规则确定证据时机。

## Must Include

- 普通任务先有效自测，同页面批次统一留证。
- 固定版本的最终界面证据与CR可并行，合并验收，无须再开零问题确认轮次。
- 代码变化按受影响状态复验复审；真实界面缺口不能靠减少检查掩盖。

## Must Not

- 每个fixer无条件全套审计或截图。
- 禁止首轮CR前采集已有稳定版本证据。
- 用自测冒充完整界面验收，或放行未覆盖的后续改动。
