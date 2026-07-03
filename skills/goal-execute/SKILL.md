---
name: goal-execute
description: Execute a prepared .goal package for complex features. Use when the user asks to run, resume, or continue a Goal, execute from .goal/status.yaml next_slice, orchestrate worker / validator / reviewer subagents, or enforce slice-by-slice implementation with validation, CR files, deferred controls, mock cleanup, and global exit checks.
---

# Goal Execute

Goal Execute 默认采用 orchestrator-worker 模型：主 agent 负责编排、证据审计、状态更新、合并和提交；实现、验证、CR 和局部修复可以委派给受控子 agent、worker session 或 worktree worker。

## 使用时机

- 用户说“按 Goal 执行 / 续跑 goal / 从 status.yaml 的 next 继续 / 连续跑完这些切片”。
- 目标 feature 已有 `.goal/GOAL.md`、`.goal/slices.yaml`、`.goal/status.yaml`。
- 复杂实现需要跨上下文恢复，并要求每个切片经过实现、验证、CR、修复、状态更新和 commit。

## 非适用场景

- 还没有通过 Goal Gate 的 feature；先读取 `references/stages/goal-handoff.md` 生成并检查 Goal 包。
- 轻量改动、单文件 bugfix 或不需要结构化恢复的短任务；使用 `references/stages/implementation.md`。
- 方案、需求或 Design CR 仍有 Blocking Pending；回到对应阶段。

## 必读输入

在执行任何代码改动前，按序读取：

1. 目标业务项目的 `README.md`、`AGENTS.md`、`CLAUDE.md` 和相关本地规则。
2. `.goal/status.yaml`。
3. `.goal/slices.yaml` 中 `next_slice` 对应切片。
4. `.goal/GOAL.md`、`.goal/acceptance.md`、`.goal/design-handoff.md`、`.goal/review-policy.md`、`.goal/mock-ledger.md`、`.goal/worktree-plan.md`、`.goal/human-intervention.md`、`.goal/resume.md`、`.goal/risks-deferred.md`。
5. 当前切片列出的 `required_docs`。
6. `git status`、当前分支、最近 commit。

聊天历史不是权威来源。若聊天与 `.goal/status.yaml` 冲突，以 `status.yaml` 为准；若 `status.yaml` 与 git 明显冲突，先核对并回写状态。

## 主 Agent 职责

主 agent 是 orchestrator / final integrator，只做这些事：

- 读取 `.goal/status.yaml`、当前 slice 和执行契约。
- 为 implementer / fixer / validator / reviewer 生成最小执行包。
- 审计子 agent 输出：scope、diff、测试、验证证据、CR findings、mock ledger、worktree 状态。
- 判断问题归属：局部实现问题交给 implementer / fixer，验证脚本问题交给 validator，设计偏差回到方案阶段。
- 只有主 agent 可以更新 `.goal/status.yaml`、合并 worktree、提交 commit、推进下一片。

主 agent 不应把所有实现细节长期带在主线程里；它应依赖文件化报告恢复上下文。

## 子 Agent 职责

- implementer / fixer：只改当前 slice scope 内文件，输出 `.goal/runs/<slice>-<role>-<n>.md`。
- validator：运行可验功能、contract test、smoke、mock 清理检查，输出 `.goal/validation/<slice>-<kind>-<n>.md`。
- reviewer：做 scoped CR，输出 `.goal/cr/<slice>-round-<n>.md`。
- worktree worker：仅在 `worktree-plan.md` 允许时使用，必须遵守 ownership 和 merge order。

子 agent 禁止：

- 直接修改 `.goal/status.yaml` 推进状态。
- 合并 worktree、提交 commit 或决定下一片。
- 扩大 slice scope，或修改未授权的共享契约。
- 用聊天回复代替文件化报告。

## 执行循环

```text
读取 status.yaml + slices.yaml[next]
→ 若有未提交改动，收敛 current_slice
→ 主 agent 生成当前 slice 执行包
→ 派发 implementer / fixer 完成当前 slice.scope
→ 派发 validator 运行 slice.tests、contract、smoke 或 mock 清理检查
→ 派发 reviewer 生成 .goal/cr/<slice>-round-1.md
→ 主 agent 审计报告和 diff
→ 修复所有 CR findings（含 Nit/P2）并复验
→ 复审直到没有未关闭 findings，或仅剩 Human Intervention TODO
→ 运行 Goal Exit 检查
→ 更新 status.yaml
→ commit
→ 工具和上下文允许时继续下一 slice
```

每个切片只能在 Exit 全部满足后标记 done。worker report 缺失、验证失败、CR 未关闭 findings、未登记 mock、status 未更新都不能 commit。若仅剩必须人工介入的问题，按 Human Intervention 规则登记；Goal 最终状态不能标 `complete`。

## 状态机

`status.yaml` 是唯一执行状态源。推荐状态：

- `ready`
- `in_progress`
- `test_failed`
- `cr_pending`
- `cr_changes_requested`
- `blocked`
- `needs_human_intervention`
- `complete`

进入切片时：

- `execution.current_slice` = 当前 slice。
- `execution.state` = `in_progress`。

切片完成时：

- 当前 slice 状态改为 `done`。
- `execution.next_slice` 指向下一片；最后一片为 `null`。
- `execution.current_slice` 清空。
- `last_cr` 指向最后一轮 `.goal/cr/<slice>-round-<n>.md`。
- 更新 `counters.open_blocker`、`counters.open_cr_findings`、`counters.open_deferred`、`counters.open_human_intervention`、`counters.http_mock_count`。

执行中如果存在 active workers，`status.yaml` 应记录 worker id / role / slice / report path / state。worker 完成不代表 slice 完成；只有主 agent 完成 Exit 审计后才能推进。

## 验证要求

可验功能应尽早验证，不要积压到最后：

- UI mock smoke：验证页面、操作矩阵、loading / empty / error / 权限态。
- API contract test：验证 DTO、状态码、错误码、mock policy。
- Service / job test：验证被依赖业务逻辑、状态流、幂等、重试。
- Mock 清理检查：验证 mock ledger 对应项已关闭。
- Integration smoke：验证写 API、读 API、页面可见结果和失败态闭环。

验证报告必须写入 `.goal/validation/`，并作为 CR 输入。测试绿不能替代验证报告；验证报告也不能替代 CR。

## CR 要求

代码改动默认必须有文件化 CR。每轮 CR 独立落盘：

```text
.goal/cr/<slice>-round-<n>.md
```

CR 文件必须包含：

- reviewer kind：`subagent` / `external` / `self`。
- reviewer role：Domain / Architecture / FE / Backend / DB / AI Pipeline / Delivery / Release 等。
- 当前 slice 和任务范围。
- 输入的 worker report 和 validation report。
- 已运行测试命令及结果。
- acceptance 覆盖表。
- Findings：Blocker / Should-fix / Nit。
- 每条 finding 的关闭状态：`fixed` / `rejected_false_positive` / `human_intervention`。
- `Open findings: 0` 才能进入正常 commit。

禁止：

- 主 agent 在 `status.yaml` 中直接写 `Blocker=0` 冒充 CR。
- 用“测试绿”“build 绿”“实现子 agent”代替 CR。
- 用 validator report 代替 CR。
- 用 worker report 代替验证或 CR。
- CR 文件不存在时 commit 代码改动。
- 遗留 Nit/P2 或 Should-fix 不处理。

如果环境不支持子 agent，只有在 `.goal/GOAL.md` 或 `.goal/gate.md` 明确允许 self review 时，才能写 `reviewer kind: self`，并必须标注原因。

## CR 修复循环

默认所有 CR findings 都必须关闭，包括 Nit/P2：

```text
运行验证
→ 子 agent CR
→ 修复 Blocker / Should-fix / Nit
→ 对误报写 rejected_false_positive 及理由
→ 重跑受影响验证
→ 再次 CR
→ 直到 open findings = 0
```

只有 agent 无法独立解决、必须人类介入的问题，才能登记为 Human Intervention TODO。它不是普通 Deferred，也不是 CR waiver。

Human Intervention 必须同时满足：

- 代码中有 `TODO(human-intervention:<slice>)` 注释，说明为什么 agent 不能解决。
- `.goal/human-intervention.md` 登记 `id`、`source_slice`、`reason`、`user_visible_impact`、`code_stub`、`required_human_action`。
- `status.yaml.counters.open_human_intervention > 0`。
- 最终 `execution.state` 只能是 `needs_human_intervention`，不能是 `complete`。

## Deferred 规则

默认不允许 Deferred。

仅当阻塞来自外部环境、第三方依赖、预发资源或用户明确接受的非本轮风险时，才能写入 `.goal/risks-deferred.md`。每条必须包含：

- `id`
- `source_slice`
- `expires_at_slice`
- `user_visible_impact`
- `code_stub`
- `owner_or_resolution`

最后一个 slice 禁止在 `open_deferred > 0` 时标记 done 或 complete。Deferred 必须关闭；如果风险仍需保留，Goal 应进入 `blocked` 或 `needs_human_intervention`，不能用 waiver 把 open Deferred 转成完成。

## Exit 检查

每个 slice commit 前必须确认：

- `slice.tests` 必跑项 exit 0，或失败原因已写入 `status.yaml.execution.state: blocked`。
- `.goal/runs/<slice>-*.md` 中必要 worker report 存在，且 scope 未越界。
- `.goal/validation/<slice>-*.md` 中必要验证报告存在，或缺失原因已写入 slice exit / status。
- `.goal/cr/<slice>-round-<n>.md` 存在，且除 Human Intervention 外 `Open findings: 0`。
- 没有新增未登记 HTTP mock、fixture-only 读路径或 pending API。
- `.goal/mock-ledger.md` 与代码中的 mock / pending API 一致。
- worktree worker 已按 `.goal/worktree-plan.md` 合并或登记阻塞。
- 没有遗留未处理 Nit/P2、Should-fix 或普通 TODO。
- `status.yaml` 已更新为下一状态。
- commit message 包含 slice id 和主要 task id。

最后一片还必须确认：

- `execution.next_slice: null`。
- `counters.open_deferred: 0`。
- `counters.open_blocker: 0`。
- `counters.open_cr_findings: 0`。
- HTTP mock 计数为 0 或白名单有书面 waiver。
- P0 acceptance 全部通过或 waiver。
- `.goal/mock-ledger.md` 无 open 项，或所有 open 项都有书面 waiver。
- smoke A/B 状态明确。
- 若 `open_human_intervention > 0`，最终状态必须是 `needs_human_intervention`，并在最终回复列明人为介入项。

## 允许停止

只有以下情况允许结束执行：

- `next_slice: null` 且 global exit 全绿或有书面 waiver。
- `status.yaml.execution.state: blocked`，并写清不可恢复原因、证据和下一步需要谁处理。
- `status.yaml.execution.state: needs_human_intervention`，且自动可处理项已经全部完成。
- 用户明确要求停止或暂停。
- 工具/上下文硬上限；此时先尽量把当前 slice 收敛到可恢复状态，并更新 `status.yaml`。

禁止在普通切片边界用自然语言问“是否继续”。切片之间应继续 tool call；如果工具限制导致无法继续，最终回复必须指出可恢复入口是 `.goal/status.yaml`。

## 上下文压缩

Goal Execute 不主动新开替代线程。上下文压缩不是停止理由，也不是开新线程理由。

允许主 agent 在当前 Goal 内调度受控子 agent、worker session 或 worktree worker 来降低主线程上下文压力；这些 worker 不是恢复权威，也不能替代当前 Goal 主线程。

恢复规则：

```text
读 .goal/status.yaml
→ 读 .goal/slices.yaml[next_slice 或 current_slice]
→ 读 .goal/resume.md
→ 读当前 slice 最近的 .goal/runs、.goal/validation、.goal/cr 报告
→ git status / git log
→ 继续当前 slice 或下一 slice
```

禁止为了上下文压缩提交半成品 checkpoint commit。只有达到安全边界才 commit：

```text
实现完成 → 验证绿 → CR open findings=0 或仅剩 Human Intervention → status 更新 → commit
```

如果上下文或工具硬上限临近但没有达到安全边界，只更新 `status.yaml` 和 `.goal/resume.md` 到可恢复状态，不 commit。

## 输出

执行中给用户的同步保持简短：

- 当前 slice。
- 已完成的验证。
- 下一步。

最终完成时汇报：

- 完成的 slices 和 commits。
- 关键 worker / validator / reviewer 报告。
- 关键测试 / smoke。
- CR 状态。
- Deferred / waiver / Human Intervention 清单。
- 与设计契约的偏差。
