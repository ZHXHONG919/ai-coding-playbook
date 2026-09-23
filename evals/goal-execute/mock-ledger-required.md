# 评测：模拟依赖必须可追踪并完成替换

## Prompt

T1 先加几个 GET mock 给页面用，后面自然会换真实接口，不用记录了。

## Expected Route

`ai-coding-playbook` → `goal-execute`；读取 `references/delivery/goal-v3.md` 与项目约定。

## Must Include

- 记录每个模拟依赖的用途、影响、责任人和退出条件，可用现有记录并从当前任务或 status 约束引用。
- goal.yaml 保留本次真实读取的用户结果、替换工作和集成依赖；暂时模拟不能算结果通过。
- 最终按约定验证真实路径；仍缺失的本次必需能力记 open_gaps，不能 complete。

## Must Not

- 只说后面替换而无责任或检查点。
- 把 HTTP mock 数量、build 通过或自行 waiver 当成真实验收。
- 为了模板完整再建一套重复的进度台账。

## Regression Notes

检查实际判断、操作和证据；结构检查或字段存在不能证明行为通过。
