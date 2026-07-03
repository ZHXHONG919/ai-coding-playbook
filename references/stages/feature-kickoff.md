# Feature Kickoff 阶段

> 目标：在进入正式方案和实现前，准备分支、需求文档目录、方案文档和任务列表，让后续开发可追踪、可暂停、可 Review。

## 使用时机

- 用户说“开始一个需求 / 新需求开工 / 按规范建方案和任务 / kickoff / 建个需求目录 / 开始实现这个需求”。
- 用户明确希望本轮需求落盘管理，而不是只在对话里讨论。
- 普通方案咨询、代码解释、临时 Review 不进入本阶段。

## 分支检查

先检查目标业务项目的 git 状态：

- 当前分支。
- 是否有未提交改动。
- 是否有远端和默认主干，优先识别 `main`，其次 `master`。
- 项目本地 `AGENTS.md` / `CLAUDE.md` 是否声明了分支和 pull 规则。

分支处理原则：

- 如果在 `main` / `master` 且工作区干净：询问或按项目规则拉取最新代码，再按需求创建功能分支。
- 如果在功能分支：询问是在当前分支继续，还是切回主干拉最新后新建分支。
- 如果在 `release/*`、`hotfix/*` 或无法判断意图的分支：先询问，不自动切分支。
- 如果有未提交改动：不要自动 pull、切分支或 rebase，先说明风险并询问处理方式。
- 不要因为用户只是“写方案”就自动切分支；只有进入 kickoff 或实现准备时才处理分支。

功能分支命名建议：

```text
feature/YYYYMMDD-short-topic
fix/YYYYMMDD-short-topic
chore/YYYYMMDD-short-topic
```

`short-topic` 使用英文小写、数字和短横线；如果用户或项目已有命名规范，以项目规范为准。

## 需求目录

默认在业务项目中创建：

```text
docs/features/YYYYMMDD-short-topic/
```

目录内默认文件：

```text
requirements.md
plan.md
tasks.md
notes.md
```

- `requirements.md`：需求分析、需求确认基线、已确认口径、非目标、待确认阻塞项和文档一致性检查。
- `plan.md`：技术方案、领域抽象、图、接口/表/任务映射、风险和验收。
- `tasks.md`：任务列表、状态、验证、CR 结果和进度记录。
- `notes.md`：过程记录、用户补充、临时决策、非本轮 backlog。

需求分析文档和技术方案默认放在同一个 feature 目录下。`requirements.md` 是 `plan.md` 的前置输入；复杂需求没有同目录 `requirements.md` 或等价需求确认记录，不进入方案设计。

如果业务项目已有 feature 文档目录或模板，优先使用项目本地规则，但必须能从 `plan.md` 反向追溯到需求确认稿。

## 初始化内容

`requirements.md` 至少包含：

```markdown
# Requirements

## Confirmed Scope

## Non-goals

## Users / Scenarios

## Inputs / Outputs

## Complex Boundaries

## Confirmed / Pending / Assumed

## Consistency Check
```

`plan.md` 至少包含：

```markdown
# Feature Plan

## Requirement Baseline

## Goal

## Evidence

## Non-goals

## Domain Model

## Flows / Diagrams

## Engineering Mapping

## Decisions

## Test & Acceptance

## Open Questions
```

`tasks.md` 至少包含：

```markdown
# Tasks

| ID | Type | Status | Task | Dependencies | Parallel Group | Mock Policy | Files / Modules | Validation | CR | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T01 | CONTRACT / MOCK / INF / BIZ / FE / INTEGRATION / QA | Todo |  |  |  | none / create / close |  | Pending | Pending |  |

## Progress

## Review Log

## Mock Ledger

| Mock ID | Created By | Cleanup Task | Status |
| --- | --- | --- | --- |

## Parallel / Worktree Plan

| Group | Worktree Allowed | Ownership | Merge Order |
| --- | --- | --- | --- |
```

任务状态建议：

- `Todo`
- `In Progress`
- `Blocked`
- `Code Done`
- `Test Failed`
- `CR Pending`
- `CR Changes Requested`
- `Done`
- `Skipped`

## 与后续阶段的关系

- kickoff 只做工作区和产物准备，不替代方案阶段。
- 需求分析和需求确认阶段负责维护 `requirements.md`。
- 方案阶段负责基于 `requirements.md` 把 `plan.md` 写到可实现、可测试、可评审；如果发现需求基线不清，回到需求确认阶段。
- 方案讨论阶段采纳反馈时必须同步同目录相关文档：需求口径改 `requirements.md`，方案结构改 `plan.md`，实现边界改 `tasks.md`，页面流程改 `ui-flow.md` / `prototype/`。
- 实现阶段按 `tasks.md` 小步推进；每完成一个任务必须经过实现、测试、CR 闸口后才能标记 `Done`。
