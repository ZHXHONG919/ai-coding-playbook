# Workflow v2 独立 CR

结论：当前候选存在需要修复的检查器误放行、调度死锁及调用方口径冲突，尚不能签收。本报告只记录具体可复现的问题；严重度由主线程结合本次验收最终裁决。

## 范围与独立性

- 候选：`/Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook-workflow-v2`。
- 基线/当前 HEAD：`8b59b6a2bfa41686128480fde3873cf122dee81b`；审查其到当前未提交工作区的规则、脚本、模板、调用方及新增评测/功能契约。
- 先检查规则与 checker 实现，再读取现有测试及评测预期。未读取其他 Agent 审计报告、历史讨论或盲测回答；主线程在检查期间告知两个快照反例和一个批次环线索，涉及项均独立复现。脚本边界由本审查者委派的独立子审查补充，并由本审查者重跑。
- 没有修改候选、原 main、安装链接或业务仓库。`.goal` 新增执行报告仅属主线程留证，不在本次独立语义审查输入中。

## 发现

### 1. [P1] 空文件清单可作为 accepted 批次的有效快照

- 位置：`scripts/check-goal.rb:141–157`，尤其第 156 行只比较历史 `files.keys`。
- 触发：正常生成 B01 accepted 快照后，将 `files` 改为 `{}`，保留 `contract_paths`；再改变被审业务文件。
- 实际：checker 仍返回 `true`。核心契约只是被要求出现在 `contract_paths`，没有要求其摘要实际在 `files` 中；空映射也被接受。
- 影响：损坏或不完整清单可以继续支撑 accepted；后续基础依赖可能依据没有绑定任何实际内容的证据继续。最终批次的全量比较不能保护之前已经放行的基础依赖。
- 最小修复：验证清单的必要条目和摘要完备性，至少禁止空清单并保证声明契约均有摘要；保留后续无关新文件不自动作废早期批次的合理行为。
- 复现：`ruby /tmp/check-goal-empty-manifest-repro.rb`，输出 `empty_accepted_manifest checker=true`。

### 2. [P1] in_review 丢弃版本变化结果

- 位置：`scripts/check-goal.rb:291–293`。
- 触发：任务 implemented，为 `src.rb=before` 固定快照并把 B01 设为 in_review；随后写入 `src.rb=after`。
- 实际：`validate_snapshot` 已算出变化，但调用方不检查返回值，checker 返回 `true`。
- 影响：恢复/检查流程无法发现当前验证与 CR 输入已经失效，违背 `references/stages/review.md` 的同一固定版本要求。
- 最小修复：in_review 对已覆盖输入的实际变化报错，提示重新冻结或回到待审状态；新增独立范围需按明确范围策略处理。
- 复现：`ruby /tmp/check-goal-edge-repro.rb`，输出 `in_review_changed_content checker=true`。

### 3. [P1] 只检查任务依赖环，Ready 会放行无法推进的批次安排

- 位置：`scripts/check-goal.rb:251–260`；与第 225 行依赖 accepted 条件、第 292 行整批 implemented 条件共同触发。
- 反例 A：`S01(B01) → S02(B02) → S03(B01)`，任务图无环。S02 等 S01 accepted；B01 等 S03 implemented；S03 又等 S02，形成批次等待环。
- 反例 B：同一个 foundation B01 中，S01、S02 都是 before_dependents，S02 依赖 S01。S02 等 S01 accepted；B01 审查又等 S02 implemented，同样死锁。
- 实际：两个配置的 Ready 检查均返回 `true`；S01 implemented 后启动 S02 报“依赖 S01 尚未达到继续条件”，尝试审查 B01 报“审查前任务必须 implemented”。
- 影响：宣称可执行的 Goal 开工后没有合法下一动作，必须修改任务/批次契约才能恢复。
- 最小修复：检查实际批次等待关系，而不只检查 slice DAG；拒绝跨批次循环和当前语义下 foundation 批次内的 accepted 自依赖，并给出可操作的拆分提示。
- 复现：`ruby /tmp/check-goal-deadlock-repro.rb`，两个 Ready 均为 true，后续执行与批次审查均失败。

### 4. [P2] 已覆盖文件的可执行位变化不会使最终快照失效

- 位置：`scripts/check-goal.rb:37–42`。
- 触发：修改已跟踪文件并完成 B01、FINAL 和 complete；再把该文件权限从 0644 改为 0755，或反向取消已审脚本的可执行位。
- 实际：`git diff --summary` 明确出现模式变化，checker 仍返回 `true`，因为普通文件仅哈希字节。
- 影响：最终审查未完整绑定实际 Git 交付改动；可执行脚本可能在审查后变得不可执行，仍保留完成状态。
- 最小修复：快照身份加入 Git 有意义的文件类型/可执行模式；不需要扩展为检查所有操作系统权限。
- 复现：`/tmp/check-goal-edge-repro.rb` 的 `completed_mode_change checker=true`。

### 5. [P2] 最新最终审查已覆盖可选契约删除，仍被历史快照永久阻塞

- 位置：`scripts/check-goal.rb:155` 调用 `capture`，在第 59 行失败；未能到第 303–304 行最终覆盖旧证据的判断。
- 触发：基线包含可选 `review-policy.md`，B01 accepted 时将其列为契约；之后删除此文件，将默认策略引用移到其他当前契约，FINAL 的新清单已明确记录删除为 null。
- 实际：即使 FINAL 完整覆盖当前状态，checker 仍报“契约文件不存在：.goal/review-policy.md”。
- 影响：经过合法变更和最终复审后无法完成；只能保留已不需要文件或重写旧快照，破坏历史证据的可追溯性。
- 最小修复：区分历史清单完整性和当前文件新鲜度。允许历史契约的删除进入 changed，再交给最终覆盖/定向复审判断；当前核心契约仍需存在。
- 复现：`/tmp/check-goal-edge-repro.rb` 的 `deletion_in_final=true`、checker=false。

### 6. [P1] 使用说明仍允许无独立能力时直接用自审代替正式 CR

- 位置：`docs/conversation-usage.md:189`，位于本次修改的“按任务实现”示例内。
- 触发：用户按此示例执行功能批次，当前环境没有可用 scoped CR 子 Agent，且项目未授权 self review 例外。
- 实际指令：“不可用时按 Review 姿态自审并记录”。它没有限定为轻量任务或要求项目明确例外。
- 影响：可据此把正式功能批次的独立 CR 降为实现者自审；与 `skills/goal-execute/SKILL.md` 的“缺少独立能力，到审查边界明确缺口；项目明确允许才例外”相冲突。
- 最小修复：该段委托给统一 Review 规则，并保留普通轻量自审与正式批次独立审查的边界。

### 7. [P2] 旧调用方与回归预期仍会把已取消的固定仪式加回来

这些是同一同步遗漏，不建议拆成多轮独立修复：

| 位置 | 具体触发与影响 | 当前权威口径 |
| --- | --- | --- |
| `references/stages/bugfix.md:24`，`evals/bugfix/source-agnostic-evidence-budget.md:16` | 一组可可靠隔离的普通 bug 因“Goal/批量问题”在收尾默认跑全量；前者还固定要求先审后做最终视觉证据 | 证据规则按实际影响决定全量，同一版本证据可与 CR 并行 |
| `README.md:271` | 复杂长链路方案一律先建 Goal，否则不得实现 | 新规则按用户要求、跨上下文恢复或多依赖交付批次的实际需要选择 |
| `AGENTS.md:60` 的 Review 路由 | 局部 CR 被要求读取整个 `references/review-kit/*`，与本次“只按相关风险读专项”相反 | `skills/ts-code-review/SKILL.md:12` 与 review-flow 按改变的规则选择 |
| `evals/goal-execute/ui-drift-once-per-slice.md:16–25` | 同版本视觉证据与 CR 并行会命中“首次 CR 前不得制作最终截图”；零阻塞后仍必须再找独立确认人 | 已修改的 final-evidence-confirmation-code-gate 明确不强制新增确认轮次 |
| `evals/goal-handoff/goal-package-required.md:18` | 无延期风险/集中索引需求的 Goal，也必须生成 risks-deferred、design-handoff | 新最小包将二者明确为按需文件 |

另需同时核对新增 8 个场景的 `expected_route`：目前全部包含 goal-execute，但 03 只要求“给最小修复和自测范围”、04 只裁决 finding，输入没有 Goal 上下文。若该字段用于路由评分，正确选择 bugfix/review 会被错判；不要用这些场景反向强化轻量任务必进 Goal。当前 README 的人工判定仅明确评分 must_include/must_not，因此这项属于评测口径缺陷，不声称已观察到真实误评分。

## 验证结果

- `bash scripts/check-playbook.sh --repo-only`：通过。当前内置 `18 runs / 44 assertions`；8 场景只检查结构，不执行 Agent。确认本命令没有读取/修改全局安装链接。
- `git diff --check 8b59b6a`：通过。
- `/tmp/check-goal-empty-manifest-repro.rb`：19 tests / 45 assertions；新增断言验证当前错误放行确实发生。
- `/tmp/check-goal-edge-repro.rb`：21 tests / 54 assertions；新增断言验证陈旧审查、模式漏查及历史契约误阻塞。
- `/tmp/check-goal-deadlock-repro.rb`：20 tests / 58 assertions；新增断言验证两类 Ready 后无合法下一动作。
- 上述数量各自包含同一套内置测试，不相加冒充不同覆盖。临时测试断言的是当前缺陷行为；修复后应反转为拒绝或允许合法情况的回归断言。

## 修复后复核范围

快照格式/新鲜度/历史覆盖为一组；任务与批次等待关系为一组；调用方与评测同步为一组。分别复核上述反例及相邻合法路径，重跑 checker 套件与仓库检查即可，无需重新展开所有专项或业务项目测试。结构检查不能替代最终独立场景验证，也不能证明报告内容真实。
