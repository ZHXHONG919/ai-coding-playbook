# Cursor 使用说明

> AI Coding Playbook 在 Cursor 中的安装方式，以及 Rules 与 Skills 的分工。

## 安装（全局 Skill）

```bash
cd /path/to/ai-coding-playbook
bash scripts/install-skills.sh --target cursor
```

若本地已有旧副本（非软链），加 `--force` 覆盖：

```bash
bash scripts/install-skills.sh --target cursor --force
```

安装结果：

- 目标目录：`~/.cursor/skills/`
- 方式：软链到本仓库 `skills/*`，或 `platforms/.build/cursor/*`（有 overlay 的 skill）
- 生效范围：**所有 Cursor 项目**均可触发，但规则正文按需读取

验证：

```bash
ls -la ~/.cursor/skills/
bash scripts/check-playbook.sh
```

## Rules vs Skills

| 机制 | 位置 | 生效方式 | playbook 放什么 |
| --- | --- | --- | --- |
| **User Rules** | Cursor Settings → Rules | 用户全局，可能常驻 | 不写 playbook 全文；最多一句薄指针 |
| **Project Rules** | `.cursor/rules/*.mdc` | 当前项目，`alwaysApply` 或 `globs` | 只放业务项目事实，由项目自己维护 |
| **AGENTS.md** | 项目根目录 | workspace rule | 业务项目维护；playbook 提供 `agents/` 模板 |
| **Skills** | `~/.cursor/skills/` | 命中 description 后加载 | playbook 维护全部通用 skill |

### 推荐分工

```text
playbook  →  Skills + references/     （跨项目方法论，按需加载）
业务项目  →  AGENTS.md + .cursor/rules （项目事实，常驻/条件常驻）
```

打开业务项目时，Agent 应：

1. 先读项目 `AGENTS.md` / `.cursor/rules`。
2. 研发类请求触发 `ai-coding-playbook` 等全局 skill。
3. 项目事实优先于 playbook 默认规则。

## 业务项目可选接入

从 playbook 复制模板，再补项目事实：

```bash
cp agents/AGENTS.template.md /path/to/project/AGENTS.md
cp agents/cursor-rules.template.mdc /path/to/project/.cursor/rules/playbook-discipline.mdc
```

`cursor-rules.template.mdc` 只含跨项目极简纪律，不含端口、域名、发布命令。

## 维护

| 改什么 | 改哪里 | 然后 |
| --- | --- | --- |
| 研发流程/门禁 | `references/` | 无需重装，下次 Read 即生效 |
| 通用 skill 正文 | `skills/<name>/` | 无 overlay 的 skill 软链后直接生效 |
| Cursor 触发描述 | `platforms/cursor/overlays/<name>.md` | 重新 `install-skills.sh --target cursor --force` |
| 业务发布/命令 | 业务项目 `AGENTS.md` | 不动 playbook |

## 与 Plan / Agent 模式

- 方案、需求确认、设计 CR：优先 Plan 模式或明确「先不改代码」。
- 按 `tasks.md` 落地：Agent 模式小步实现。
- 复杂 design CR：可用 scoped 子 agent 分模块评审，再汇总。

## 对话示例

```text
参考 ai-coding-playbook，先为这个需求做需求确认，先别写代码。
```

```text
按 playbook 评估这次 diff 的测试范围。
```

```text
对这个 plan.md 做设计 CR，看能不能进入 tasks。
```
