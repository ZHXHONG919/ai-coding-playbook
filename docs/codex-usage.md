# Codex 使用说明

> AI Coding Playbook 在 Codex 中的安装与维护方式。

## 安装（全局 Skill）

```bash
cd /path/to/ai-coding-playbook
bash scripts/install-skills.sh --target codex
```

若 `~/.codex/skills/ai-coding-playbook` 等目录是旧副本而非软链：

```bash
bash scripts/install-skills.sh --target codex --force
```

安装结果：

- 目标目录：`~/.codex/skills/`
- 方式：软链到本仓库 `skills/*`，或 `platforms/.build/codex/*`
- `ai-coding-playbook` 使用中文宽触发 overlay（`platforms/codex/overlays/ai-coding-playbook.md`）

验证：

```bash
ls -la ~/.codex/skills/
readlink ~/.codex/skills/ai-coding-playbook
bash scripts/check-playbook.sh
```

如果规则或 skill 看起来没有生效，先按 `references/stages/rule-diagnostics.md` 排查：它到底是没有关联、没有加载、没有读到，还是读到了但缺少可执行门禁。

## 生效方式

- **Skill**：全局注册，命中触发词后加载。
- **references/**：不自动注入；skill 路由后按需 Read。
- **业务项目 AGENTS.md**：打开对应项目时优先。

## 维护

| 改什么 | 改哪里 | 然后 |
| --- | --- | --- |
| 研发流程/门禁 | `references/` | 直接生效 |
| 通用 skill 正文 | `skills/<name>/` | 软链 skill 直接生效 |
| Codex 触发描述 | `platforms/codex/overlays/<name>.md` | `install-skills.sh --target codex --force` |
| 路由或门禁回归样例 | `evals/` | `check-playbook.sh` 结构检查；人工回放样例 |
| 业务事实 | 业务项目 | 不进 playbook |

## 对话示例

```text
参考 ai-coding-playbook，按规范启动这个需求：建方案和任务目录，先写方案。
```

```text
参考 ai-coding-playbook，对当前改动做 Review，先列 P0 风险。
```

## 业务 skill 共存

业务 CLI skill（如 `lumeseed-ai`）由各业务项目自己的安装脚本维护，与 playbook 全局 skill 并存。install 脚本只管理本仓库 `skills/` 下的 skill；遇到同名非软链目录且未加 `--force` 时会跳过，避免误删业务 skill。
