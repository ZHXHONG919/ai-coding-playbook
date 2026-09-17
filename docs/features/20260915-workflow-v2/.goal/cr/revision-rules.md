# 工作流 v2 本轮规则独立审查

## 当前结论

在本次指定的规则范围内，修复后未发现尚未解决的阻塞问题。初审发现的正常回写被拦截、前端固定验证流程残留均已向主线程报告；主线程修复后，已根据原反例定向复核。

这份结论是规则一致性和反例推演结果，不证明真实项目的耗时、token 或交付后缺陷已经下降。审查者未改候选文件、未安装、未提交、未访问业务目录，也未阅读主线程或此前 CR 的通过报告。

## 发现与定向复核

### R1：正常回写进度被脏工作区门禁拦截（已修复）

- 初审位置：`references/stages/feature-kickoff.md:9,18,32` 与 `references/git-safety.md:51`；相冲突的执行要求在 `skills/goal-execute/SKILL.md:99,103`。
- 触发：用户已授权当前功能分支实现但未授权提交；首任务完成、自测通过，工作区有本任务自己的修改。接着回写 `.goal/status.yaml` 或执行证据。
- 影响：旧表述把任何 `.goal/*` 修改都送回文档门禁，再因有未提交改动要求停下询问；普通任务无法按 continuous 约定正常恢复记录。若不提交后续每次回写都会再次触发。
- 修法：区分同一获授权功能分支中的正常文件编辑，与切换分支、合并、rebase 等 Git 操作；已核实归属的任务修改允许继续回写，不明或重叠修改先核实保护。
- 复核位置：`references/stages/feature-kickoff.md:30-32`、`references/git-safety.md:51-53`。现文本明确上述例外，原反例不再触发停工；主干限制及 Git 命令授权边界保留。

### R2：React 入口仍把 build/test 列为固定验证步骤（已修复）

- 初审位置：`skills/react-vite-feature/SKILL.md:37-41`；与 `skills/test-scope-analysis/SKILL.md:32-38`、`references/delivery/evidence-driven-delivery.md:13,90` 冲突。
- 触发：仅改已授权页面文案或间距，现有运行态查看足以证明变化，项目没有要求完整包构建和测试。
- 影响：沿前端专用入口会运行整个 web 包 build/test，把已经收窄的最小验证范围重新扩大；审查或修复再走同一入口时会重复执行无新增观测的检查。
- 修法：明确按类型、装配、构建及业务交互影响选择相关命令；保留项目必需检查与用户可见运行态证据。
- 复核位置：`skills/react-vite-feature/SKILL.md:39-43`。现已按风险选择检查，且保留真实界面校准及视觉/交互/业务三类验收。原反例无需固定跑全部 build/test。

### R3：使用指南仍要求每次前端修复 polish 后再 audit（已修复）

- 初审位置：`docs/conversation-usage.md:140-145,188-190`；与 `references/stages/review.md:58-59`、`references/stages/implementation.md:37-39` 冲突。
- 触发：同一批次已验收主要布局，CR 修复局部错误提示或无视觉影响的逻辑，再按用户指南执行。
- 影响：指南的固定 polish→audit 和笼统重做 UI Drift Gate，会恢复完整审计循环；旧 `Passed / Fixed / Blocking / Skipped` 摘要也没有承接新版三维验收，容易把源码修复状态当成还原结论。
- 修法：指南引用同一采用稿和统一实现/审查规则，按实际风险选择方法、只复验影响区域和状态，复用有效证据；分别说明视觉还原、交互一致、业务正确。
- 复核位置：`docs/conversation-usage.md:144-147,188-190`。现已明确不固定 polish 再 audit，原反例已消除。

## 另外核对的反例

以下是本审查者按规则构造的静态推演，未冒充真实执行实验。

| 反例 | 依据及判断 |
| --- | --- |
| 用户在实现完成后新增校验，随后发生返工 | `execution-evidence.md:28-34` 要求对照当时有效需求、区分新变化与原要求遗漏、保留裁决；不应计成初版代码缺陷。 |
| 旧代码和旧测试都允许某行为，但有效业务规则明确禁止 | `requirement-confirmation.md:53,61`、`test-scope-analysis:44-45` 要求区分现状与认可目标，旧测试通过不能裁决产品口径。 |
| CR 提出新产品偏好，被主线程拒绝；同一缺陷被多个 reviewer 各报一次 | `execution-evidence.md:33-34,44` 按裁决及问题族统计；不会把全部评论数当缺陷数。 |
| 不知道引入节点、模型用量或等待起止 | `execution-evidence.md:11,28-31,40-47` 要求未知/不完整，不倒推原因、不补零、不把并行耗时相加。 |
| 同一版本重复 CR 与修复之后针对失败路径复查 | `execution-evidence.md:43`、`review.md:44-48` 明确区分无新依据重复与必要复验，不把所有第二轮都算浪费。 |
| 用户确认 v3 原型，另有未采纳 v4；组件库默认样式或 polish 建议更改密度 | `evidence-driven-delivery.md:46-57`、`fullstack-ui-prototype:130-132,151` 要求采用稿编号/版本/允许差异并实际打开；确认效果优先，不能用默认值或通用美化覆盖。 |
| 原型只能读源码，无法获得运行预览 | `evidence-driven-delivery.md:55-57,67,73` 允许记录缺口、推进无依赖工作；不能以源码或测试通过完成视觉验收，也不能无限重试或扩散同一未验证布局。 |
| 用户将自行验收页面，Agent 已修改源码 | `review.md:54`、`validation-report.md:13` 保持“还原待验收”，不把未来人工检查当已通过；没有新增重复确认授权要求。 |
| 首个页面已校准，后续 fix 只影响一个状态 | `implementation.md:35-39`、`review.md:59` 规定受影响复验，未变证据可复用；不要求每任务截图或新 CR 批次。 |
| 少量事件被模板展开成多份重复摘要 | 新 `execution-evidence.md:24` 明确短任务一个事件表加少量归因、合并缺失指标、引用原报告；`execution-log.md:3,21` 允许复用，不要求新建文件或抄写 finding。 |
| 原验收任务的前置输入变更，但实际代码已存在 | `goal-execute:35,90-95`、`goal-handoff:45,53` 和状态模板有 awaiting_revalidation 与范围复验规则；静态规则没有要求退回 todo 重做所有实现。检查器是否正确实现另有专项审查。 |

## 已查范围与局限

- 逐段检查指定四份交付/执行记录文件、四份阶段入口、四份技能；交叉读取 Goal 交接与状态/报告模板、方案轻重选择、任务拆解、业务决定来源及审查总则。
- 相邻入口检查包括 AGENTS、入口技能、项目模板、使用指南及 README 相关说明。README 只对本轮相关入口/说明作定向核对，不声称全文事实核验。
- 没有审查 `scripts/check-goal.rb`、`scripts/test-check-goal.rb` 或结构检查器实现，未运行真实 Goal、浏览器或产品验收；没有采用结构脚本通过作为行为正确证据。
- 没有评价此前策略实验的有效性或通过结论，也没有用主线程转述的实验结果替代独立观察。
- 初次审查时，Git add/commit 的广义门禁仍要求“任何 Git 写操作”前工作区为空；当时只确认正常文件回写例外。该条历史限制现已由本文末尾的“两处追加规则定向复核”覆盖，不能继续据此判断当前版本仍有同一矛盾。
- 后续实际应用仍应从真实执行记录观察成本与缺陷；本次证据足以判断以上具体规则冲突已消除，不能据此承诺零缺陷或整体效率提升。

## 终版文件摘要

下列摘要标定本次已读或定向检查的版本。后续文件变化不能直接沿用本结论，需按影响复核。

- 候选目录：`/Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook-workflow-v2`
- 初次摘要采集时间（UTC）：2026-09-16T03:18:32.237993+00:00；下面五份追加复核文件已更新为 2026-09-16T03:26:59.169839+00:00 的摘要，其余条目保持原版本。

| 文件 | SHA-256 |
| --- | --- |
| `AGENTS.md` | `f202b5d1114bdbea75b4e2facbb05a83a5c8f2485ed1c674f0bab228b80690cb` |
| `README.md` | `13ccf4bb92c4707b1eec58cd8bcb0f1dc971f9f9b4c82ea8236b2e2700d8d022` |
| `agents/AGENTS.template.md` | `634659ab8b4d86633fecb2ee8a6c1b63cfc6b48fef443b74c7e11fca4d86d635` |
| `docs/adoption-guide.md` | `eb7dcacbbc51c4a95edb6a965cf51b7b1226e260210835edac70afe8af1fce42` |
| `docs/conversation-usage.md` | `5d028ab04949398f2b71cd3b22e96dc3aa525a87bdc7b17f1dd60aa6465d6c1b` |
| `docs/codex-usage.md` | `3f89361d5ee0988cf92d34483c2c4dc8749e7dea26d1573b95f39147c8c18d4a` |
| `references/delivery/execution-evidence.md` | `91f1ebac5da2d715afbac5fe4991212f915b7cf686e82b5f4654258d92c3ccab` |
| `templates/execution-log.md` | `6303ec5a827fe28a0920d0d412f8d09ec0455c1a6864c543a58475590294e9b4` |
| `references/delivery/agent-delivery-flow.md` | `378b218de8310108a281456d9a349664c566d208d3c8deb4621574c118fdd08a` |
| `references/delivery/evidence-driven-delivery.md` | `134fff28021884614bf59c45a88c71764227adb03e407263403ed55d1d953a1c` |
| `references/stages/feature-kickoff.md` | `87abd5656adb8a3133f8335431c4af5fed331672f5d7b94873cf9b79241b4d6c` |
| `references/stages/implementation.md` | `eddcedd739f700b54ed989071edc52426ccd123b8d89e71e2b7d30ea271fb6ee` |
| `references/stages/review.md` | `720eb82908722e0300ff20bdbcdf9e83b905216f766eb84a305f00c5dff2081b` |
| `references/stages/requirement-confirmation.md` | `30de7ef5c84c092d3ad95d73abd7095fe66f91239f52bec94fe9b4d39144a5a4` |
| `references/stages/goal-handoff.md` | `7f34b325c8df49bbb26b987c43b50ad40ca0970dbd3bd049f244042f97ae352b` |
| `references/stages/plan-light.md` | `b97c5e08cdc2297476898c31996ed3196978a610d137091d4b2f30c8f0e93c6c` |
| `references/stages/plan.md` | `abffb7355aca43efe2edaa3f4c63f73d9472123104cb2c0f1202ad395ed3fa61` |
| `references/plan/task-breakdown.md` | `29fd7d05ac6bbc37581b5d27ffda1ab7bacc5f68a42ddadd09d676b5eb67f151` |
| `references/plan/decision-table.md` | `e4e27ab76b550ffe018e7ff5176b81dac1f26340a7cd7149698a97176cd5cb9b` |
| `references/review-kit/review-flow.md` | `5b44a7641717ec798ae658e7a11f28d6388fb914f92e07922b2cb08a7fd88cb5` |
| `references/git-safety.md` | `d7f2d94c7cde1742d0dfcde3288568c333979291efa2edcfcd6fa5791765ec66` |
| `references/delivery/tooling-prerequisites.md` | `e7d9601c5128654d4e2cf51752477ca5969fe387dcea5b0f907c9e6996c2c694` |
| `skills/ai-coding-playbook/SKILL.md` | `9e2e3d50f6ac760afc0654d8303060446ac0ce8a9b2aa48721b51c50c141a434` |
| `skills/goal-execute/SKILL.md` | `6654fa2e349e06fc0fccd79d35bf0538ffbe74249c036d345ba0a603770c77fb` |
| `skills/fullstack-ui-prototype/SKILL.md` | `835c2314cb27ddcd0cd312ac140ed4f9d68f781107120585e33b9c963ccd2fce` |
| `skills/react-vite-feature/SKILL.md` | `d0b0ea67cbb087aa124967e1f145b76d479a6decd12ccc20d366d3cb4b4e7bd1` |
| `skills/test-scope-analysis/SKILL.md` | `97696cddf40a09fb25afa2b035b1117463d072051f1f9a5989469a06d9d7daa3` |
| `skills/ts-code-review/SKILL.md` | `330fb4bc250356acd575e0f37151b306a9fd11b9a655474b8237045440ed447e` |
| `skills/skill-maintenance/SKILL.md` | `86f2014b41987fa0a0cc746062bded382276ea6b0d3f47ac398eef22c15232b6` |
| `templates/goal/validation-report.md` | `c6b6c1fcfbc0578111495c9a02f14838ab39c3f8a4d725e58e08ad4cb1b8192d` |
| `templates/goal/worker-report.md` | `49bba791cf4ccd05f4e11a087df21620b77dfc8d146083450da5b2ba9890cd68` |
| `templates/goal/design-handoff.md` | `d94ac15234723b80498d55722a874c3b533f79c405a0c1950dafe93742c1c042` |
| `templates/goal/cr-template.md` | `9165e452ec7be9dd7a37da1ad3064eef177b7b219a96bebe81f429d94a262199` |
| `templates/goal/acceptance.md` | `2c516bd4a8954b0ef11319d0b65aaf372595bb17760d2fdf5ff663abc2aa73e3` |
| `templates/goal/review-policy.md` | `8adcf643d3eda0be19876acbe3406451f250bbe596f6750397f5b947c751170e` |
| `templates/goal/slices.yaml` | `ced3c117f047d8737bd1d1cdc181fa5a4328b96f4a0ec9e68c05f069f3c2412e` |
| `templates/goal/status.yaml` | `d8f382f3ebdaa6b368bf5c5a2c1ef800aeff15dc33c881d41b4110b11f33558b` |
| `evals/git-safety/authorized-checkpoint.md` | `7ef004008706f52232af5aeaaaa99280c3821e7798384ba38eb1864f2fd1cdde` |
| `evals/git-safety/no-automerge-main-into-feature.md` | `4d2899018f3b6155ad22540ae413ff8bf17edee26642f2e029d6da659a0273e0` |

## 两处追加规则定向复核

结论：本次新增范围未发现阻塞问题。未重审无变化实现、未读取检查器脚本、未执行任何 Git 写操作。以下是规则与反例的一致性核对，不是实际仓库提交或检查器执行测试。

### A. 已授权的 add/commit 检查点

- 位置：`references/git-safety.md:30,43-55`；场景 `evals/git-safety/authorized-checkpoint.md:5-15`；既有 no-automerge 场景第 22 行。
- 原矛盾及修复：工作区有待提交改动时不可能同时满足“先为空”。第 47 行现在明确将 add/commit 分流到检查点规则，第 51 行要求已有提交授权、核对本任务差异及暂存区、按明确路径暂存且只提交授权内容；`goal-execute/SKILL.md:105` 的已自测检查点现在有可执行的 Git 规则。
- 反例 1：仅有本任务修改、暂存区为空、已有“只提交不推送”授权。允许核对后提交，不需消除修改或再次授权；仍为 implemented，不能跳到 accepted。
- 反例 2：另一个任务已经有暂存内容。必须先核实保护，不能将其带入检查点或为方便提交自动取消用户暂存；仅有本任务提交授权不足以处理别人的暂存。
- 反例 3：用户只授权编辑。该授权不能升级为 add/commit、push 或 merge；保留可恢复工作区即可。
- 反例 4：用户要求 merge/rebase，并提出 autostash；或切换分支时存在改动。检查点例外不适用，工作区条件、项目 PR-only 规则与明确操作授权仍须满足。若同一操作已有适用授权，不再要求重复授权，但该授权不消除其他前提。
- 与原规则关系：同分支正常文档/状态回写例外仍存在；检查点依旧不代表验收或允许推送。初次报告中的 Git 提交限制在这个具体范围内已消除。

### B. 跨批次共享验收编号

- 位置：`skills/goal-execute/SKILL.md:33-43,91-97,111-116`；`references/stages/goal-handoff.md:44-46`。对照状态模板与 `review.md:23,46-48`，没有发现新冲突。
- 反例 1：B01 是 A01 唯一完整证明，R01 进入 awaiting_revalidation。B01 不再提供有效通过证据，A01 必须 pending；旧 final 汇总报告不能单独保留 passed。
- 反例 2：B02 另有当前快照有效、已验收且完整证明同一 A01 的记录，B01 的无关范围返修。A01 可以引用 B02 保持 passed；R01/B01 仍未验收，消费者不能因 A01 标签跳过其任务依赖，Goal 也不能完成。
- 反例 3：B01 只证明输入、B02 只证明输出，两者却共用“完整端到端成功”的 A01。新规则明令禁止不同局部结果共用同一完整断言，不能以 B02 的局部通过替代 B01 待复验。
- 反例 4：声称 B02 仍有效，但共享契约或真实依赖已变。快照和实际影响规则仍要求回退受影响批次；不能仅因 B02 的状态字面上还是 accepted 就维持 A01 passed。
- 反例 5：只有 final 报告或未验收的第三个批次声称 A01 通过。它们都不满足“另一当前有效、已验收的非 final 批次”，不能作为保留陈旧 passed 的理由。
- 该规则区分“这个固定断言已有当前有效证明”与“所有关联任务都完成”，没有把 passed 用作跳过 awaiting_revalidation、依赖门禁或全 Goal accepted 的通行证。它是否由检查器准确实现，仍归专项脚本审查负责。

### 本次摘要更新范围

仅更新前表中的 `references/git-safety.md`、`skills/goal-execute/SKILL.md`、`references/stages/goal-handoff.md`，并新增 `evals/git-safety/authorized-checkpoint.md` 和 `evals/git-safety/no-automerge-main-into-feature.md`。其余已审文件及结论未因本次复核而扩大覆盖范围。
