# Adoption Guide

> 这份指南说明如何把 AI Coding Playbook 接入研发工作流。
> 原则：playbook 只管跨项目方法论；业务项目事实留在业务仓库。

## 1. 旁路使用

最安全方式是先把本项目当参考资料，让 AI 读取：

- `AGENTS.md`
- 对应 `references/stages/*`、`references/plan/*`、`references/scenarios/*`

复杂需求先用 `references/stages/requirement-confirmation.md` 收口，再进入方案。

## 1.1 AI-Ready 预检查

业务项目接入 AI-SDLC 前，先按 `references/scenarios/ai-ready.md` 做一次轻量检查。重点不是追求完美，而是确认 AI 能找到入口、跑起项目、知道测试和发布边界。

推荐先补齐：

- 项目 `README.md`、`AGENTS.md` / `CLAUDE.md`。
- 安装、启动、构建、测试、smoke 命令。
- 高风险目录、生产发布、凭据和外部写入边界。
- 关键模块、数据流和测试数据说明。

如果 AI-Ready 结论是 `Not Ready`，先补项目入口和最小验证链路，再引入复杂多 Agent 协作。

## 2. 安装全局 Skills（推荐）

```bash
cd /path/to/ai-coding-playbook
bash scripts/install-skills.sh --target codex --force
bash scripts/install-skills.sh --target cursor --force
bash scripts/install-skills.sh --target claude --force
```

安装后 skill 在对应工具的全局目录生效，**所有项目**均可按需触发。

| 工具 | 全局 skill 目录 | 说明文档 |
| --- | --- | --- |
| Codex | `~/.codex/skills/` | [`docs/codex-usage.md`](codex-usage.md) |
| Cursor | `~/.cursor/skills/` | [`docs/cursor-usage.md`](cursor-usage.md) |
| Claude Code | `~/.claude/skills/` | [`docs/claude-usage.md`](claude-usage.md) |

验证：

```bash
bash scripts/check-playbook.sh
ls -la ~/.codex/skills/
ls -la ~/.cursor/skills/
```

## 3. Cursor Rules 与 Skills 分工

- **playbook**：维护 `skills/` + `references/`（按需加载）
- **业务项目**：维护 `AGENTS.md`、`.cursor/rules/*.mdc`（项目事实，常驻或按 globs）

可选复制极简纪律模板：

```bash
cp agents/cursor-rules.template.mdc /path/to/project/.cursor/rules/playbook-discipline.mdc
```

详见 [`docs/cursor-usage.md`](cursor-usage.md)。

## 4. 接入业务项目 AGENTS

如果业务项目还没有 `AGENTS.md`：

```bash
cp agents/AGENTS.template.md /path/to/project/AGENTS.md
cp agents/CLAUDE.template.md /path/to/project/CLAUDE.md
```

如果已有 `AGENTS.md`，不要覆盖；人工合并通用纪律，并补充项目事实（命令、发布、端口、高风险目录）。

**业务 CLI skill**（如 `lumeseed-ai`）由各业务项目自己的安装脚本维护，不放进 playbook。

## 5. 推荐接入顺序

1. `ts-code-review`
2. `test-scope-analysis`
3. `typeorm-postgres-migration`
4. `release-safety-review`
5. `design-review`（复杂方案进实现前）
6. `nest-api-design` / `react-vite-feature`
7. `fullstack-ui-prototype`
8. `ai-provider-integration` / `browser-extension-development`
9. `skill-maintenance` / `skill-prompt-convert`
10. `codegen-diagram` / `codegen-doc`

## 6. 维护方式

| 改什么 | 改哪里 |
| --- | --- |
| 研发流程/门禁 | `references/` |
| 通用 skill 正文 | `skills/<name>/` |
| Codex 触发描述 | `platforms/codex/overlays/` |
| Cursor 触发描述 | `platforms/cursor/overlays/` |
| 规则/skill 回归样例 | `evals/` |
| 业务发布/命令/模块 | 业务项目 `AGENTS.md` |

修改 overlay 或首次安装后，重新执行对应 `install-skills.sh --target <tool> --force`。

## 7. 维护原则

- 通用规则改 playbook。
- 项目事实改业务项目。
- 两个以上项目反复出现的规则，才考虑从业务项目上提到 playbook。
- 规则疑似不生效时，先按 `references/stages/rule-diagnostics.md` 定位断点，再决定是否改规则。

## 8. 当前 Goal 执行方式

需要连续执行和跨上下文恢复时，只使用 Goal v3。轻量修改无需建包。先列完整用户结果和共享基础，再滚动展开近期工程任务；每条用户路径由一个 owner 负责贯通。

最小包有两份常驻文件：

- `.goal/goal.yaml`：结果预期、用户决定、可定位来源、结果依赖与工程任务。任务只引用结果，不重复写产品预期。
- `.goal/status.yaml`：任务的 `todo / in_progress / done` 状态及有序核验记录。恢复时按需保存 `next_action`、`constraints`、`active_workers` 和 `open_gaps`。

普通任务完成必要自测后记 `done` 并继续就绪工作；共享基础在被消费前取得当前有效的独立核验。完整用户结果可运行时，独立核验者先根据当前约定形成判错样本并运行验证，再读实现报告审查完整差异。一份 `runs/*.yaml` 可以同时记录行为结论和代码发现，引用实际证据，不要求每种角色各建报告。

用户改变要求时更新决定及受影响结果，递增 revision；新改动按真实影响使相关结果和依赖待核验，保留未受影响的有效证据与历史 run。任务全 done 不代表 Goal 已通过；全部必需结果有当前有效证据、完整差异没有遗漏且无活动写入者或必需缺口，才可完成。开发交付和生产发布分别记录。

模板与执行说明见 [最小模板](../templates/goal-v3/goal.yaml)、[Goal Handoff](../references/stages/goal-handoff.md) 和 [按结果交付](../references/delivery/goal-v3.md)。结构检查示例：

```bash
ruby scripts/check-goal.rb --template templates/goal-v3
ruby /path/to/ai-coding-playbook/scripts/check-goal.rb /path/to/project/docs/features/example/.goal
```

检查器不执行真实验收，也不能证明预期或证据正确。旧格式执行器、模板和兼容模式不再提供；不能仅修改版本号、补空字段或沿用旧通过状态伪造当前执行包。

## 9. 隔离验证规则变更

用户要求暂不应用时，在独立工作树修改和验证，保持已安装 skills 的软链接及源目录不变，不运行安装脚本。使用 `bash scripts/check-playbook.sh --repo-only` 做仓库检查；行为评测按 [evals 说明](../evals/README.md) 实际执行并保留原始记录，不能把历史成绩改写成新规则的成绩。
