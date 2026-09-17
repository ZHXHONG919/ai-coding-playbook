# AI Coding Playbook

> 这个仓库用于沉淀跨项目可复用的 AI coding 工作流、Agent 规则、文档模板和 Skills。
> 它不是业务项目，不包含任何业务代码、生产凭据、内部平台地址或具体客户信息。

## 这个项目解决什么

旧项目里沉淀了大量 AI coding 实践：分阶段设计、Code Review、测试范围分析、黑白盒验证、发布前检查等。
新项目 `lumeseed` / `lume-tuber` 的技术栈已经切换为 pnpm monorepo、NestJS、React、Vite、TypeORM、PostgreSQL、Chrome Extension 和 AI provider 集成。

本项目的目标是把这些经验抽象成通用资产：

- 让 AI 先理解、计划、验证，再改代码。
- 让 feature 设计、测试、发布和回滚有固定检查点。
- 让新需求从分支、方案文档、任务列表到功能验收与审查都可追踪。
- 让 Git 分支操作保持可控：默认只做只读检查和 `git fetch`，不擅自本地 merge / rebase 主干或绕过 PR 保护。
- 让不同项目共享同一套基础 Skills，而项目细节仍留在业务仓库自己的 `AGENTS.md` 中。
- 避免把历史公司的业务、平台、Java 技术栈、内部工具绑定到新项目。

## 推荐目录结构

```text
ai-coding-playbook/
├── README.md
├── agents/                 # 可复制到业务项目根目录的 Agent 行为规则模板
├── references/             # 新版活规则：阶段、方案、review-kit、场景专项
├── workflows/              # 旧版工作流说明，保留兼容已有引用
├── templates/              # Feature 方案模板：复杂 feature-design、轻量 plan-light、PR、migration
├── skills/                 # 可安装到 ~/.codex/skills、~/.cursor/skills、~/.claude/skills 的通用 Skills
├── evals/                  # 规则、skill 路由和输出门禁的人工/脚本评测样例
├── platforms/              # 各工具 overlay 与安装 manifest（Codex / Cursor / Claude Code）
├── profiles/               # 旧版技术栈 profile，逐步迁移到 references/scenarios
└── scripts/                # 安装、同步、检查脚本
```

## 最轻使用方式

不需要安装、不需要复制模板，也不需要改业务项目。日常使用时，不必反复说长提示；在业务项目上下文里直接说阶段意图即可：

```text
梳理需求
做方案
拆任务
执行任务
继续 Goal
做 CR
测试范围
发布检查
上线 / 发测试 / 发生产
```

如果当前窗口有多个项目，第一次加目标项目即可：

```text
目标项目 lume-tuber，做方案。
```

AI 应该自动读取目标业务项目自己的 README / AGENTS / CLAUDE / docs，再把本 playbook 当作通用方法论使用。项目事实永远优先于 playbook 默认规则。

更详细的对话用法见 [`docs/conversation-usage.md`](docs/conversation-usage.md)。

## 候选规则验证与隔离

用户要求暂不应用时，先检查已安装目录是否软链接到当前仓库；在独立工作树/副本修改与验证，保留安装源和链接。`--repo-only` 只检查候选仓库，不检查或建议同步全局安装。安装必须等用户明确通知。

## 候选交付主线

按“明确结果 → 组织工作 → 实现 → 核验 → 交付”组织职责。各节点共用结果、约束、事实、范围、验证与返回信息，按当前需要加载；主线程负责整体判断。局部能力缺失时依据稳定契约隔离依赖，让可执行部分继续，并保留真实能力和集成验收。详见[节点职责与交接](references/delivery/agent-delivery-flow.md)。

## 用证据优化执行策略

执行 Goal 或试用新策略时，在已有任务边界留下选择理由、实际结果和证据引用。复用原记录或一份[执行记录模板](templates/execution-log.md)，通过[记录方法](references/delivery/execution-evidence.md)区分需求变化、实现缺陷、验证遗漏和重复检查。时间/token 缺失如实标注，不增加逐工具报告，不以单次模拟宣称效率提高。

## Clone 后快速开始

别人下载这个仓库后，先做一次自检：

```bash
cd ai-coding-playbook
bash scripts/check-playbook.sh --repo-only
```

然后按需要选择一种用法。

### 1. 只作为参考库

不安装任何东西，直接在业务项目对话里引用本仓库路径：

```text
参考 /path/to/ai-coding-playbook，目标项目 <your-project>，梳理需求。
```

后续就可以直接说：

```text
做方案。
执行任务。
继续 Goal。
做 CR。
```

### 2. 安装为 Codex / Cursor / Claude Skill

安装后，AI 工具更容易自动识别“梳理需求、做方案、执行任务”等短指令：

```bash
bash scripts/install-skills.sh --target codex
bash scripts/install-skills.sh --target cursor
bash scripts/install-skills.sh --target claude
```

默认安装到对应工具的 skills 目录，只安装本仓库 `skills/` 下的通用 skill，不修改业务项目。

### 3. 接入某个业务项目

如果希望业务项目长期按这套规则协作，可以复制 Agent 模板到业务项目，再补充项目事实：

```bash
cp agents/AGENTS.template.md /path/to/project/AGENTS.md
cp agents/CLAUDE.template.md /path/to/project/CLAUDE.md
```

复制后应在业务项目文档里补充本地启动命令、测试命令、发布脚本、数据库迁移规则和禁止 AI 擅自触碰的目录。

## 如何使用

### 方式一：只作为参考库

直接阅读：

```bash
cd /Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook
less README.md
```

适合还在打磨规则阶段。

### 方式二：把通用 Agent 规则复制到业务项目

```bash
# 例：复制到某个业务项目，复制后请人工补充项目特有内容
cp agents/AGENTS.template.md /path/to/project/AGENTS.md
cp agents/CLAUDE.template.md /path/to/project/CLAUDE.md
```

复制后应补充业务项目自己的：

- 本地启动命令
- 测试命令
- 发布脚本
- 生产域名和端口
- 数据库迁移规则
- 不允许 AI 擅自触碰的目录或流程

### 方式三：安装通用 Skills

```bash
bash scripts/install-skills.sh --target codex
bash scripts/install-skills.sh --target cursor
bash scripts/install-skills.sh --target claude
```

- 默认 Codex 目标：`~/.codex/skills/`
- 有平台差异的 skill（如 `ai-coding-playbook`）会合并 `platforms/<tool>/overlays/` 后软链
- 旧副本目录用 `--force` 替换为软链

工具专用说明：

- [`docs/codex-usage.md`](docs/codex-usage.md)
- [`docs/cursor-usage.md`](docs/cursor-usage.md)
- [`docs/claude-usage.md`](docs/claude-usage.md)

```bash
AI_CODING_SKILLS_DIR=/path/to/skills bash scripts/install-skills.sh --target cursor
```

脚本只安装本仓库 `skills/` 下的通用 skill，不修改业务项目。

## 资产分层

| 层级 | 放在哪里 | 是否跨项目共用 | 说明 |
| --- | --- | --- | --- |
| AI 行为边界 | `agents/` | 高 | 不乱改、不越权发布、先验证后收尾 |
| 活规则 | `references/` | 高 | 阶段路由、Git 安全边界、kickoff、方案门禁、review-kit、场景专项 |
| 工作流 | `workflows/` | 高 | 旧版 feature、review、test、release、incident，保留兼容 |
| 文档模板 | `templates/` | 高 | 复杂方案 `feature-design.md`、轻量方案 `plan-light.md`、PR、migration |
| Skills | `skills/` | 高 | Code Review、测试范围、设计 CR、Nest API、React feature 等 |
| 评测样例 | `evals/` | 高 | 验证 skill 路由、输出门禁和规则遵守是否可回归 |
| 平台适配 | `platforms/` | 高 | Codex / Cursor / Claude 的 frontmatter overlay 与安装 manifest |
| 技术栈画像 | `profiles/` | 中 | Nest/React/Postgres、Chrome Extension、AI pipeline |
| 业务事实 | 业务项目自身 | 低 | 域名、端口、模块名、凭据、发布机、具体数据表 |

## 维护原则

1. 这里沉淀“跨项目原则”，不要写业务专属逻辑。
2. 任何示例都使用占位符，不出现真实凭据、真实客户数据。
3. Skill 要描述判断标准和执行流程，不要绑定某个公司内部工具。
4. 如果某条规则只适合一个项目，放回那个项目的 `AGENTS.md`，不要放到这里。
5. 修改工作流或模板后，优先用一个真实小需求回放验证。
6. 修改 skill description、阶段路由或门禁后，补充 `evals/` 样例，确保能复查“规则是否真生效”。

## 证据驱动交付

`references/delivery/evidence-driven-delivery.md` 统一正常开发和问题修复的验证口径：问题可以来自对话、工单、截图、日志、监控、测试或代码审查；任务按风险选择证据等级，界面任务在 `tasks.md` 声明界面基线和证据门禁。截图用于证明用户可见结果，不作为所有任务的固定动作；批量问题按用户路径和共享根因聚类。最终视觉证据与 CR 可在同一固定版本并行完成，合并到批次验收；修复后只复核受影响状态，全量回归按实际影响与项目要求决定。

`references/delivery/tooling-prerequisites.md` 统一第三方工具准备：任务开始前列出所需 CLI、连接器/API、安装和认证状态；优先使用已有 CLI 和结构化接口，缺失的必要 CLI 从可信来源安装到项目或用户范围。浏览器和桌面控制只用于无法结构化完成的授权与视觉验证，避免与用户正在进行的操作冲突。

## 当前通用 Skills

| Skill | 用途 |
| --- | --- |
| `ai-coding-playbook` | 入口路由 Skill，触发后读取本仓库 `AGENTS.md` 与活规则 |
| `design-review` | 方案、需求和界面流程设计审查，作为进入实现前的门禁 |
| `goal-execute` | 按 `.goal/status.yaml` 协调复杂功能的实现者、验证者和审查者分片执行 |
| `ts-code-review` | TypeScript、NestJS 和 React 代码审查 |
| `test-scope-analysis` | 从代码差异或方案推导测试范围 |
| `release-safety-review` | 发布前安全检查、回滚和冒烟计划 |
| `nest-api-design` | NestJS API、DTO、Guard、Swagger 设计与评审 |
| `react-vite-feature` | React + Vite 页面、状态、表单和 API 集成 |
| `fullstack-ui-prototype` | 全栈功能的界面流程、页面原型和静态流程验证 |
| `typeorm-postgres-migration` | TypeORM 实体与 PostgreSQL 迁移设计/评审 |
| `ai-provider-integration` | AI 提供方、降级、成本保护和冒烟验证 |
| `browser-extension-development` | Chrome 插件、内容脚本、后台脚本和采集流程 |
| `skill-maintenance` | 创建、维护、评审和沉淀多工具 Agent Skill |
| `skill-prompt-convert` | 提示词、AGENTS/CLAUDE 规则与 SKILL.md 互转 |
| `codegen-diagram` | 基于项目事实生成 Mermaid 架构图、ER 图、状态图、数据流图 |
| `codegen-doc` | 基于项目事实生成项目文档、模块说明和交接材料 |

## Open Design 接入

Open Design 是可选的设计探索工作台，不是所有前端任务的必经步骤。推荐在这些场景使用：新页面或大改版、多版视觉方向比较、复杂后台/运营/审核/批量操作交互路径、用户明确要求先看设计稿或使用 Open Design。

不推荐在这些场景使用：单字段、单按钮、文案、间距、颜色、局部组件状态、已有确认设计稿后的代码实现。

Open Design 产物进入工作流后，应记录到 `ui-flow.md`、`prototype/` 说明或 Goal design handoff：projectId、studioUrl/previewUrl、entry file 或 artifact bundle、采用版本、拒绝版本、待确认问题和跳过原因。它只提供设计输入；主用户路径、审核对象、权限、状态流和 API/ViewModel 契约仍以需求确认和方案文档为准。

实际使用 Open Design 时，按 `references/scenarios/open-design.md` 执行：先定位或创建项目，再通过 `start_run` 委托 Open Design 生成/细化设计，轮询 `get_run` 到终态，最后用 `get_artifact` 拉取源文件作为实现和 UI Drift Gate 的证据。

## Impeccable 接入

`impeccable` 是目标业务项目可选安装的前端/UI 质量增强 skill。playbook 不把它当作通用必装 skill；只有目标项目存在 `.agents/skills/impeccable/SKILL.md` 时才启用，未安装时不阻塞流程。

默认阶段映射：

- UI Flow 或静态原型前：需要新建或重构页面结构时按 `impeccable shape`。
- 原型完成后：按 `impeccable critique` 做视觉层级、信息架构、清晰度和 AI UI 反模式检查。
- 实现完成后：按 `impeccable audit` 做可访问性、响应式、性能、溢出和状态覆盖检查。
- CR 后前端 fix：按 `impeccable polish` 修视觉、布局、文案和状态细节，修完再按 `impeccable audit` 复验；担心偏离原型时补 `impeccable critique`。
- 风格专项问题：按问题选择 `impeccable bolder`、`impeccable quieter`、`impeccable colorize`、`impeccable layout`、`impeccable clarify`。

impeccable 只能修 UI 质量和表达，不能覆盖已确认的主用户路径、审核对象、权限、状态流或 API/ViewModel 契约；发现这些变化必须回到 UI Flow / 方案阶段做 Change Sync。

## 规则生效诊断与评测

`references/stages/rule-diagnostics.md` 用于排查“规则配置了但 agent 没照做”的问题。诊断时先区分四层：

- 关联：文件、skill 或工具是否存在于可发现位置。
- 加载：本轮上下文是否实际读到入口或元数据。
- 读到：agent 当前步骤是否把规则纳入判断。
- 遵守：输出或动作是否符合可检查门禁。

`evals/` 保存可复查样例，用来验证 skill 路由和输出门禁。它不是替代真实项目验证，而是给 playbook 自身提供回归基线。


## 新版全站规则结构

`references/` 是当前优先维护的规则入口：

```text
references/
├── stages/       # 需求、需求确认、kickoff、方案、实现、Review、Bugfix、发布阶段
├── plan/         # 技术方案质量门禁：证据、角色视角、领域抽象、图表、细节、任务
├── review-kit/   # 通用 Review 流程和专项检查清单
└── scenarios/    # LLM 分析、AI 媒体、Chrome 插件、Nest/React/Postgres、pnpm monorepo 等
```

需求到方案的核心原则：复杂需求进入方案前必须先做需求确认，把多轮讨论里的已确认口径、非目标、待确认阻塞项和文档冲突收口；需求阶段提出的问题必须在需求阶段处理，方案阶段只基于已确认需求做论证、建模和工程设计。涉及复杂后台、运营、审核或批量操作时，按“需求分析 -> 需求确认 -> 页面流/审核对象草图 -> 技术方案草案 -> 静态原型/UI Flow -> 方案回写 -> 设计 CR -> 方案定稿 -> 任务拆解 -> 实现”的顺序推进。

方案阶段的核心原则：先用业务、领域、架构、交付和 Review 视角补齐盲区，再做轻量领域抽象，不套完整 DDD；复杂方案在任务拆解或实现前做 scoped design CR；涉及复杂后台页面、运营流程、审核流或批量操作时先补 UI flow，必要时用静态原型验证页面风格和业务流程；最后用图表和细节把方案落到可编码、可测试、可评审。涉及前端项目和 API 交互时，`tasks.md` 默认采用 Frontend-first Mock Lane：先冻结交互契约，再以前端功能和 mock 数据跑通用户路径，随后实现服务端能力并逐步替换 mock。用户要求 Goal 或实际需要结构化跨上下文恢复时，通过 Goal Handoff 将方案和任务转为执行契约；轻量改动无需 Goal。

实现阶段默认按功能批次审查：普通任务最小有效自测后继续，共享规则的变更在依赖方开始前审查；批次独立验证与 CR 可在同一固定版本并行，主线程裁决并按影响范围修复复核。`implemented` 表示实现和自测通过，`accepted` 表示已审查并验收。最终核对完整差异和用户结果，代码交付与发布分别报告。详见 [流程与节点图](references/delivery/agent-delivery-flow.md) 和 [Goal 执行规则](skills/goal-execute/SKILL.md)。旧 Goal 按原契约恢复，切换策略须记录依据。
