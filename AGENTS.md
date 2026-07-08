# AI Coding Playbook 入口

> 跨项目复用的 AI coding 规则库。目标是在普通对话里稳定识别研发阶段，先做好抽象和方案，再进入实现、测试、Review 和发布。

## 默认行为

轻量使用 playbook。不要在帮助用户前要求安装、复制文件或做初始化。

处理业务项目时：

1. 先读目标项目自己的 `README.md`、`AGENTS.md`、`CLAUDE.md` 和相关文档。
2. playbook 只提供通用方法论。
3. 项目本地事实优先于 playbook 默认规则。
4. 如果 playbook 与项目文档冲突，遵循项目文档，并简短说明冲突。

触发后用一句短话标明阶段，例如：“我按 ai-coding-playbook 进入方案阶段，先不改代码。”

## 自然语言短指令

用户不需要每次说“参考 playbook”。只要当前对话在业务项目或本 playbook 上下文中，下面这些短语就应按阶段路由自动触发：

| 用户短语 | 默认阶段 |
| --- | --- |
| 梳理需求 / 分析需求 / 看下这个需求 | 需求分析 |
| 确认需求 / 对齐口径 / 收口需求 | 需求确认 |
| 做方案 / 写方案 / 方案设计 / 技术设计 | 方案阶段 |
| 做 UI Flow / 画页面流 / 做原型 / 看页面路径 | UI Flow / 静态原型 |
| 拆任务 / 拆实现 / 拆 task | 任务拆解 |
| 执行任务 / 开始实现 / 按方案落地 / 落地这个需求 | 实现阶段 |
| 继续任务 / 继续 Goal / 续跑 / 按 status.yaml 继续 | Goal Execute |
| 做 CR / review / 检查风险 | Review 阶段 |
| 测什么 / 测试范围 / 测试策略 | 测试范围分析 |
| 发布检查 / 回滚方案 / Go No-Go / 部署 / 部署下 / 部署一下 / 上线 / 发版 / 发测试 / 发生产 | 发布阶段 |
| 排查问题 / 看报错 / bugfix | Bugfix / 排障 |

如果当前窗口有多个项目或目标不明确，先轻问一句目标项目；如果用户已说“目标项目是 lume-tuber”或当前工作目录就是业务项目，就不要反复要求用户写长提示。

不触发场景：

- 简单命令输出、纯事实问答、闲聊或非研发问题。
- 用户只要求解释一个概念，且不涉及当前项目方案、实现、测试、Review、发布或排障。
- 单纯翻译、润色、格式整理，除非内容本身是研发规则、方案或代码 Review。

## 阶段路由

| 用户请求 | 必读规则 |
| --- | --- |
| 需求分析 / 梳理需求 | `references/stages/requirement.md` |
| 复杂需求进入方案前 / 需求确认 / 对齐口径 | `references/stages/requirement-confirmation.md` + `references/stages/requirement.md` |
| 新需求开工 / kickoff / 建方案和任务目录 / 开始一个需求 | `references/stages/feature-kickoff.md` + `references/stages/plan.md` + `references/plan/*` |
| 技术方案 / 功能设计 / 模型设计 / 架构设计 | 先判断轻量或复杂：轻量读 `references/stages/plan-light.md` + `templates/plan-light.md`；复杂先读 `references/stages/requirement-confirmation.md`，再读 `references/stages/plan.md` + `references/plan/*` + 匹配 `references/scenarios/*`，落盘用 `templates/feature-design.md` |
| 方案评审 / 设计 CR / 设计评审 | `skills/design-review/SKILL.md` + `references/stages/plan.md` + `references/plan/*` |
| 生成 Goal 包 / Goal Handoff / 执行契约 / 复杂方案转连续执行 | `references/stages/goal-handoff.md` + `templates/goal/*` |
| 开始实现 / 按方案落地 | `references/stages/implementation.md` + `references/plan/task-breakdown.md` |
| 按 Goal 执行 / 续跑 goal / 从 status.yaml next_slice 继续 | `skills/goal-execute/SKILL.md` + `references/stages/implementation.md` |
| Review / 检查代码 / 看风险 | `references/stages/review.md` + `references/review-kit/*` + `skills/ts-code-review/SKILL.md` |
| bug / 报错 / 排障 / 事故分析 | `references/stages/bugfix.md` + `workflows/incident-workflow.md` |
| 发布前检查 / 回滚方案 / 部署 / 部署下 / 部署一下 / 上线 / 发版 | `references/stages/release.md` + `skills/release-safety-review/SKILL.md` |
| 测试范围 / 测试策略 | `skills/test-scope-analysis/SKILL.md` + `references/scenarios/pnpm-monorepo.md` |
| 规则不生效 / skill 没触发 / 知识库没约束 Agent | `references/stages/rule-diagnostics.md` + `skills/skill-maintenance/SKILL.md` |
| 业务项目 AI-Ready / 接入 AI-SDLC 前检查 | `references/scenarios/ai-ready.md` + `docs/adoption-guide.md` |
| NestJS API | `skills/nest-api-design/SKILL.md` + `references/scenarios/nest-react-postgres.md` + `references/scenarios/pnpm-monorepo.md` |
| TypeORM / PostgreSQL migration | `skills/typeorm-postgres-migration/SKILL.md` + `references/review-kit/database.md` |
| React / Vite 页面 | `skills/react-vite-feature/SKILL.md` + `references/scenarios/nest-react-postgres.md` + `references/scenarios/pnpm-monorepo.md` |
| 全栈页面方案 / UI flow / 静态原型 | `skills/fullstack-ui-prototype/SKILL.md` + `skills/react-vite-feature/SKILL.md` + `references/scenarios/nest-react-postgres.md` |
| AI provider / AI 媒体链路 | `skills/ai-provider-integration/SKILL.md` + `references/scenarios/ai-media-pipeline.md` |
| Chrome 插件 / 采集链路 | `skills/browser-extension-development/SKILL.md` + `references/scenarios/chrome-extension.md` |
| Skill 创建 / 维护 / 规则沉淀 | `skills/skill-maintenance/SKILL.md` |
| Prompt / AGENTS / SKILL.md 互转 | `skills/skill-prompt-convert/SKILL.md` |
| 根据项目生成架构图 / ER 图 / 数据流图 | `skills/codegen-diagram/SKILL.md` + 匹配的 `references/plan/*` |
| 根据项目生成文档 / 模块说明 / 交接材料 | `skills/codegen-doc/SKILL.md` |

旧的 `workflows/*`、`profiles/*`、`templates/*` 暂时保留，用于兼容已有引用；新规则优先读取 `references/*`。

## 方案阶段核心要求

方案阶段默认不改代码。复杂方案必须按以下顺序推导：

```text
用户目标 / 旧方案 / 当前项目事实
→ 需求确认：已确认口径 / 非目标 / 待确认阻塞项 / 文档一致性
→ 证据来源表
→ 业务问题与非目标
→ 系统用例
→ 轻量领域抽象
→ 业务结构图
→ 流程图 / 状态图 / 数据流图
→ 工程映射
→ 表 / Entity / API / DTO / ViewModel / Job
→ 决策表
→ 任务拆解
→ 测试与验收
→ 本轮待确认问题
```

### 关键门禁

- 没有证据，不写成事实。
- 复杂方案定义：命中任一强触发项（DB/migration、状态流、异步/LLM/外部链路、权限安全计费、发布回滚补偿、跨两个以上端、用户要求多角度评审），或命中两个及以上累积触发项（多模块多文件、新 API/DTO/ViewModel/Job/页面、新业务概念、兼容旧数据/旧接口、人工审核/批量操作、异常分支、新测试策略、待确认风险、任务依赖链）。
- 复杂需求没有需求确认，不进入方案阶段；需求阶段提出的问题必须在需求阶段收口，不能拖到方案阶段决定。
- 没有区分 `Confirmed / Pending / Assumed`，不把需求分析稿当方案依据。
- 需求文档存在互相冲突的口径时，必须先做一致性检查和需求确认。
- 没有角色视角判断，不进入复杂方案细节；角色不是头衔，必须体现业务、领域、架构、交付和 Review 责任。
- 没有领域抽象，不进入表设计。
- 没有业务结构图，不进入详细表设计。
- 没有核心流程图，不进入任务拆解。
- 有状态字段，就必须有状态流转图。
- 有异步 / LLM / 审核 / 同步链路，就必须有数据流或产物流图。
- 涉及后台页面、运营流程、审核流、批量操作或复杂前端状态的全栈方案，进入任务拆解前必须补 UI flow；页面流程不直观时补静态原型或说明不需要的理由。
- 涉及后台页面、运营流程、审核流、批量操作或复杂前端状态时，原型 / UI Flow 完成后必须停下；没有用户明确确认并授权进入详细方案设计，不写详细 `plan.md`、不拆 `tasks.md`、不生成 Goal。
- 复杂方案进入任务拆解或实现前，必须经过 design CR（`skills/design-review/SKILL.md`）；用户授权且环境支持时优先唤起 scoped design CR 子 agent。
- 复杂长链路方案在 Design CR Ready 后、实现前，必须进入 Goal Handoff：生成 `.goal/` 执行契约并通过 Goal Gate；没有 `.goal/status.yaml` 和 `gate.md: Ready`，不进入代码实现。
- 复杂 Goal 执行默认采用主 agent 编排模型：主 agent 只负责读取契约、派发 worker / validator / reviewer、审计证据、更新 `.goal/status.yaml`、合并和提交；实现、验证、CR 和局部修复必须委派给子 agent / worker，主 agent 不直接编辑业务代码。只有用户明确授权 self-run，或 `.goal/GOAL.md` / `.goal/gate.md` 明确允许 `self_run_allowed: true` 时，主 agent 才能临时承担实现角色，并必须文件化说明原因、范围和风险。
- Goal 执行允许使用受控子 agent、worker session 或 worktree worker 来降低主线程上下文负担；这不等于为上下文压缩主动新开替代线程，恢复权威仍然只有 `.goal/status.yaml` 和 `.goal/resume.md`。
- Codex app 的 Goal 进度条只是 UI 可视化镜像；执行权威仍是 `.goal/status.yaml`。在 Codex 环境中，只要进入 Goal Execute 且当前工具提供 `get_goal` / `create_goal`，主 agent 应先读取项目 `.goal`，再默认创建或复用 app-level goal，并按工具契约同步完成 / 阻塞终态；仅当 `codex_app_goal.enabled: false` 或已有不匹配 active app goal 时跳过或说明冲突。不要用 app goal 替代 `status.yaml`。
- 已存在 `.goal/status.yaml` 且用户要求续跑 Goal 时，进入 `skills/goal-execute/SKILL.md`；不要用聊天历史或平行 Markdown 进度表覆盖 `status.yaml`。
- 没有字段、状态、接口、任务和验收细节，不进入实现。
- 进入 kickoff 的需求必须有 `plan.md` 和 `tasks.md`；实现阶段每个任务完成前必须经过实现、测试、CR 闸口。

## 轻量领域设计口径

领域设计不是为了套完整 DDD，而是为了做好抽象。必须回答：

1. 核心概念是什么。
2. 每个概念负责什么、不负责什么。
3. 哪些属于对象自身，哪些属于对象关系，哪些只是某次任务上下文，哪些是计算结果。
4. 概念如何创建、修改、审核、失效、重算。
5. 哪些规则必须长期稳定。

## 角色视角口径

复杂研发任务必须使用 `references/plan/role-lens.md`：

- 需求：业务负责人、产品负责人、领域建模者。
- 方案：业务架构师、技术架构师、交付负责人、资深 Reviewer。
- 实现：Senior Engineer、代码维护者、测试负责人。
- Review：Staff Reviewer、专项 Reviewer、发布风险负责人。
- 排障：Incident Commander、Debug Owner、回归验证负责人。
- 发布：Release Manager、SRE、数据负责人、业务 Owner。

输出不必机械罗列角色，但必须体现这些角色负责发现的问题、做出的取舍和剩余风险。

## 输出风格

优先高信号，不要为了形式写很长的仪式化文档。用户要正式方案时才完整展开；普通讨论可先给当前结论、关键图、决策点和待确认问题。

## 规则生效与回归

当用户质疑“规则为什么没生效”“skill 为什么没触发”“知识库是不是没读到”时，不要直接追加更多规则；先按 `references/stages/rule-diagnostics.md` 区分关联、加载、读到和遵守四层，再决定修入口、修 description、修路由、下沉到子 agent，还是补 eval。

修改 skill description、阶段路由、模板或门禁后，优先在 `evals/` 增加一个可复查样例。规则库的目标不是“文件越来越多”，而是关键行为可回归。
