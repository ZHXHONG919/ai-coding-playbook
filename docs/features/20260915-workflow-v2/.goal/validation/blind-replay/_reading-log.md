# 独立评估阅读与限制记录

## 评估范围

候选根目录：`/Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook-workflow-v2`。

先完整读取候选 AGENTS 和交付流程，再读取 8 个 `evals/workflow-v2/*/input.md`，按对应阶段阅读下列规则。没有读取 expected.json、评分结果、其他 Agent 报告或 Git 历史；没有检查业务仓库、搭建环境、调用外部服务、安装、执行 Git 操作或修改候选规则。仅在本 `/tmp` 目录写评估报告。

场景事实仅来自各自 input；报告中的验证动作是建议下一步，不是已执行的测试证据。未借其他场景补全某场景的业务事实。

## 实际阅读文件

以下路径均相对候选根目录。部分工具批量输出发生截断，缺失部分已以较小范围重读。

- `AGENTS.md`
- `README.md`
- `skills/ai-coding-playbook/SKILL.md`
- `references/delivery/agent-delivery-flow.md`
- `references/delivery/evidence-driven-delivery.md`
- `references/stages/implementation.md`
- `references/stages/review.md`
- `references/stages/bugfix.md`
- `references/git-safety.md`
- `workflows/incident-workflow.md`
- `skills/test-scope-analysis/SKILL.md`
- `references/scenarios/pnpm-monorepo.md`
- `skills/goal-execute/SKILL.md`
- `skills/ts-code-review/SKILL.md`
- `references/review-kit/architecture.md`
- `references/review-kit/database.md`
- `references/review-kit/review-flow.md`
- `references/review-kit/security.md`
- `references/review-kit/typescript-react.md`
- `skills/ai-provider-integration/SKILL.md`
- `references/scenarios/ai-media-pipeline.md`
- `references/plan/task-breakdown.md`
- `references/plan/role-lens.md`
- 8 个场景各自的 `input.md`。

尝试读取根目录 `CLAUDE.md`，文件不存在。没有因该缺失假设业务规范。

## 遇到的张力及本轮处理

### 1. 全量回归触发条件不一致

`references/stages/bugfix.md` 步骤 6 写到：Goal、批量问题、共享核心/契约/基础设施或高风险改动默认在收尾运行一次全量回归。`references/delivery/evidence-driven-delivery.md` 则明确全量回归不是 Goal、批量问题或最终收尾的固定动作，只在影响面无法可靠隔离、项目明确要求或交付风险需要时运行；测试范围和 Review 规则也要求按实际影响选择。

这会影响 03、06、07 的成本判断。本轮采用入口指定的统一 Review 细则和具体影响判断：定向复验，不因标签自动全仓回归；若实际代码显示影响不可隔离，再扩大。这里存在规则文本不一致，不是仅缺业务输入。

### 2. 必建 Goal 的口径仍有旧表述

README 的“新版全站规则结构”仍称复杂长链路方案 Design CR 后必须 Goal Handoff；候选 AGENTS 与实现规则则按跨上下文恢复需要或用户要求决定，而非复杂标签一律建立 Goal。

这 8 个场景不需要新建 Goal；07/08 按已有执行契约判断，所以没有用 README 旧说法新增执行包或暂停本轮。但未来没有 Goal 的复杂实现请求可能受该差异影响。

### 3. 专项清单阅读范围不统一

AGENTS 的 Review 路由列 `references/review-kit/*` 为必读，TS Review Skill 和 review-flow 又要求只加载匹配专项，不每轮遍历全部。本轮合并评估多个风险场景时实际读了整个 review-kit；单场景继续照此读取会增加不必要负担。核心裁决按具体场景适用规则，不把全部清单变成所有场景的固定门禁。

### 4. Provider 的通用步骤需要结合操作范围解释

Provider Skill 的“验证顺序”列真实 provider 最小 case，未在这一段再次标注范围/授权条件；入口、交付证据和 Goal 规则则区分真实调用授权与未验证边界。02 明确图片供应商无需调用，且本次评估禁止全部真实外部调用。因此不执行真实调用，05 的正常模型路径仍标为未验证。

这主要是适用范围需解释，不是声称两个规则无法同时满足。不会以通用步骤扩大用户范围，也不会用范围限制掩盖必需验收缺口。

### 5. 输入字段名与规则字段名

08 的输入用 `run_mode` 描述 continuous；Goal 规则的正式路径为 `run_control.mode`。本轮把输入当行为约束，不静默宣称实际 YAML 已符合 schema。实际执行时读取项目契约确认即可，无须为场景回放编造迁移。

## 结论边界

这些报告证明本轮对给定场景作出了怎样的决策，不能证明候选规则在真实业务实现中已降低缺陷或成本。报告没有标准答案或得分；可由其他人使用独立标准复查。
