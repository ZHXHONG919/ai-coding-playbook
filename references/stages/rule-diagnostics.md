# 规则生效诊断

> 目标：排查 playbook、项目规则、skill 或知识库“看起来配置了，但 agent 没照做”的问题。

## 核心判断

不要把规则失效笼统归因为“模型没听话”。先区分四层：

| 层级 | 含义 | 常见失败 |
| --- | --- | --- |
| 关联 | 文件、skill 或工具存在于可发现位置 | 路径错、未安装、未软链、平台 overlay 未生成 |
| 加载 | 本轮上下文实际读到了入口或元数据 | 触发描述太弱、路由表漏项、路径作用域没命中 |
| 读到 | agent 在当前步骤把规则纳入判断 | 规则太长、入口噪声太多、子 agent 上下文没继承 |
| 遵守 | 输出或动作符合规则要求 | 规则不可验证、没有门禁、权限配置放行了高风险动作 |

## 诊断流程

1. 确认目标平台和入口。
   - Codex：检查 `~/.codex/skills/`、当前项目 `AGENTS.md`、本仓库 `platforms/codex/overlays/`。
   - Cursor：检查 `~/.cursor/skills/`、User Rules、项目 `.cursor/rules/*.mdc`。
   - Claude Code：检查 `~/.claude/skills/`、项目 `CLAUDE.md` / `AGENTS.md`。
2. 确认是否已关联。
   - 运行 `bash scripts/check-playbook.sh`。
   - 检查 skill 是否为软链，overlay skill 是否指向 `platforms/.build/<tool>/`。
3. 确认是否能被路由。
   - 看用户请求是否命中 `AGENTS.md` 阶段路由。
   - 看对应 `SKILL.md` 的 `description` 是否包含适用场景和典型触发词。
   - 如果 skill 在清单里但没有触发，优先修 description 或阶段路由。
4. 确认是否读到了足够内容。
   - 入口文件只放路由和硬边界，长内容应拆到 `references/`。
   - 子 agent、后台线程或新会话需要重新读取对应 skill / reference，不能假设继承主会话上下文。
5. 确认是否可遵守。
   - 规则必须有可检查输出，例如证据表、状态图、测试命令、CR 结论。
   - 高风险动作要落到权限、门禁或确认要求，不只写“不要”。

## 常见修复

| 现象 | 优先修复 |
| --- | --- |
| 用户说了“测试策略”但没有触发 playbook | 补 `ai-coding-playbook` overlay description 或 `AGENTS.md` 路由 |
| 专项 skill 没触发 | 在 `description` 加典型触发语，避免只写抽象能力名 |
| 读了入口但没读 reference | 在阶段规则写明“必读 / 按需读取” |
| 子 agent 没守主规则 | 派发 prompt 中明确传入 skill、reference 路径和验收门禁 |
| 输出缺少证据或验收 | 把规则改成结构化输出要求，并补 eval 用例 |

## 输出格式

```markdown
## 诊断结论

- 断点层级：关联 / 加载 / 读到 / 遵守
- 证据：
- 修复建议：
- 回归验证：
```
