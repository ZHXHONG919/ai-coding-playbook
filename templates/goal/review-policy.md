# 代码审查策略

> 目标：每个 slice 的关键环节和代码改动必须经过文件化 CR。当前 slice 的阻塞项必须关闭；不影响当前 slice 主链路的问题必须分类沉淀，避免 CR 无限循环吞掉连续执行节奏。

## 默认策略

```yaml
default_required: true
default_reviewer: ts-code-review-subagent
self_review_allowed: false
validation_report_required: true
worker_report_required_for_code_changes: true
pass_condition:
  blocking_findings: 0
  p0: 0
  p1: 0
  blocker: 0
  should_fix: 0
  non_blocking_follow_up_allowed: true
  all_findings_closed_required_in_release_gate: true
human_intervention_allowed: true
max_fix_rounds_per_finding: 2
max_pre_cr_validation_rounds: 1
ui_evidence_timing:
  pre_cr: lightweight_path_and_baseline_check
  final: after_blocking_fixes_completed_before_re_review
  rerun: affected_states_only_after_ui_fix
legacy_nit_zero_on_dev_slice: false
```

## 审查矩阵

| 环节 | 触发 | 推荐审查角色 | 输入 | 输出 |
| --- | --- | --- | --- | --- |
| 契约审查 | API / DTO / ViewModel / 状态 / 模拟策略冻结 | Architecture / Backend / FE | `plan.md`、`slices.yaml`、契约草案 | `.goal/cr/<slice>-contract-round-<n>.md` |
| 界面流程审查 | 界面流程、模拟可见闭环、操作矩阵、界面偏差检查 | FE / Product Flow / Delivery | `ui-flow.md`、原型、Open Design 产物（Open Design artifact）、界面偏差验证报告、impeccable 命令记录 | `.goal/cr/<slice>-ui-round-<n>.md` |
| 基础能力审查 | 迁移、实体、共享抽象、状态机 | DB / Backend / Architecture | 实现报告、代码差异、测试 | `.goal/cr/<slice>-foundation-round-<n>.md` |
| 切片审查 | 当前切片代码实现 | Backend / FE / AI Pipeline / Delivery | 实现报告、验证报告、代码差异 | `.goal/cr/<slice>-round-<n>.md` |
| 集成审查 | 模拟清理、工作树合并、真实链路 | Delivery / Release | 验证报告、模拟台账、工作树计划 | `.goal/cr/<slice>-integration-round-<n>.md` |
| 发布审查 | 冒烟、回滚、延期风险、人工介入 | Release / SRE / Delivery | 验收、状态、风险文件 | `.goal/cr/<slice>-release-round-<n>.md` |

不要求每个 slice 都跑全矩阵；`slices.yaml` 必须声明当前 slice 需要哪些 reviewer roles。高风险环节可以多 reviewer 并行审，主 agent 负责汇总和裁决。

## 代码审查循环

```text
运行聚焦验证和代码审查前轻量界面检查
→ 写入 .goal/validation/<slice>-<kind>-<n>.md
→ 任务或并发切片通过前覆盖并发检查清单
→ 子 Agent 基于实现报告和验证报告执行代码审查
→ 写入 .goal/cr/<slice>-round-<n>.md
→ 若存在阻塞问题：修复影响当前正确性、数据/发布安全、状态一致性、接口契约或验收的问题
→ 将非当前切片问题分流到待办、后续切片、发布门禁或人工介入
→ 用证据拒绝误报
→ 只重跑受影响验证
→ 有阻塞：完成修复、准备复审前制作最终界面/原型证据，由复审同时确认修复和证据
→ 无阻塞：立即制作最终界面/原型证据，优先由原审查者确认；不可恢复时由同职责且独立于实现者的审查者接替并记录原因
→ 将限定范围确认写入 .goal/cr/<slice>-evidence-confirmation-<n>.md
→ 证据确认前比较当前代码与关联代码审查输入；运行时代码变化时重开限定范围代码审查并更新证据
→ 重复直到 blocking_findings = 0
```

吞吐规则：

- 当前切片仍有阻塞问题时，不启动无关修复任务。
- 每次修复后默认只跑受影响测试，不重复完整迁移和全量测试。
- 首次代码审查前只做轻量界面检查；完成阻塞修复、准备复审前完成最终原型对比。最终证据后运行时代码变化必须重开限定范围代码审查。
- 普通开发切片不要求 `nit: 0`，除非用户明确要求零 Nit。

同一个问题经过两轮工作者修复后仍未关闭，主 Agent 必须升级处理，不能静默循环：

- 将 `implementation_owner` 切换为 `main_thread` 或 `hybrid`，由主线程收口一轮。
- `design_sync_required`：回到需求或方案同步。
- `human_intervention`：登记到 `.goal/human-intervention.md`。
- `release_gate`：生产环境问题移到发布切片。
- `later_slice_gate`：只影响未来切片时移到对应切片门禁。
- `non_blocking_follow_up`：仅用于不影响当前正确性、数据、安全、发布、契约、验收或主路径的 P2/Nit。
- `todo_ledger`：用于局部待确认、需求优化、交互建议、契约优化和技术债，集中对齐但不阻塞下一切片。

只有 `design_sync_required`、`human_intervention`、状态过期、不可恢复的工作树/状态不一致或当前切片未解决的阻塞问题可以停止连续 Goal。后续项、未来切片项和发布门禁项登记后继续主链路。

局部待办不应停止连续 Goal，除非它使当前 P0/P1 验收无法判断、制造错误数据/权限/状态，或阻塞无法通过模拟、适配器或功能开关隔离的后续切片。

旧 Goal 包如果仍要求开发切片 `nit: 0`，默认采用本吞吐策略；只有用户或 `release_gate` 要求零 Nit 时才全部关闭。策略覆盖需记录到代码审查文件，并在下次 Goal 交接时更新模板。

## 证据规则

- 实现报告不能替代验证。
- 验证报告不能替代代码审查。
- 测试或构建通过不能替代验收覆盖。
- 只有主 Agent 可以更新 `.goal/status.yaml`、合并工作树、提交或推进下一切片。
- 代码审查输入必须包含相关实现报告、验证报告、切片契约、验收项和代码差异。

## 问题关闭

| 状态 | 含义 | 是否允许最终通过 |
| --- | --- | --- |
| `fixed` | 代码、文档或测试已更新并验证 | 是 |
| `rejected_false_positive` | 问题属于误报，代码审查文件已说明证据 | 是 |
| `human_intervention` | Agent 无法在没有人工动作时解决 | 仅已登记时允许 |
| `non_blocking_follow_up` | 不阻塞当前切片的 P2/Nit 或讨论项 | 普通开发切片允许；发布门禁需豁免 |
| `later_slice_gate` | 只影响未来切片并已登记 | 对应切片开始前允许 |
| `release_gate` | 真实环境、生产或提供方冒烟问题移到发布门禁 | 发布门禁开始前允许 |
| `open` | 尚未解决 | 否 |

## 人工介入边界

人工介入是唯一允许保留的未解决结果，只用于必须由人、外部环境、凭据、生产/预发操作、产品决策、DBA 或第三方支持完成的问题。

必须登记到 `.goal/human-intervention.md`，否则仍视为未关闭问题并阻塞提交。
