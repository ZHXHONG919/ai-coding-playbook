# 固定候选检查器独立审查

> 最新结论：修订版本中的 F1、F2 已关闭；详见文末“修复后的定向复核”。下文先保留初轮发现与失败证据。

## 结论

本次固定候选发现 2 个可复现的验收状态问题，建议修复后定向复审：

1. 待复验任务对应的验收项没有任何有效批次证明，仍可保留 `passed` 并通过检查。
2. `--template` 允许预填 `acceptance: passed`，与模板约定不符。

在亲自检查和试验的范围内，没有发现批次文件/契约变动漏失效、无关批次无故失效、基础依赖可直接跳过或最终完成条件被这两处问题绕过。这里的结论仅覆盖下面明确列出的范围；不是零缺陷承诺，也不等于真实业务功能验收。

## 独立性与范围

- 候选根目录：`/Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook-workflow-v2`。
- 亲自完整读取 `scripts/check-goal.rb`、`scripts/test-check-goal.rb`、`templates/goal/slices.yaml`、`templates/goal/status.yaml`、`evals/workflow-v2/checker.md`。
- 读取候选 README、AGENTS、Review 规则和 Goal 执行规则中的相关状态说明；未读取其他 CR 通过报告或实现者总结。
- 所有探针脚本写入 `/tmp`，测试使用临时 Git 仓库；没有修改候选、原仓、安装目录，没有安装或提交真实仓库。Git fixture 的 init/add/commit 是候选原测试及独立探针创建的临时仓库行为。
- 未重复全库 `check-playbook.sh`；主线程另做集成结构检查。

## 固定版本

审查开始与独立探针结束后核对，以下文件 SHA-256 一致：

| 文件 | SHA-256 |
| --- | --- |
| `scripts/check-goal.rb` | `277f4e6a45b54f6425781b6ed8daf5c05d2a86abfd13165d2b539028929b2c2e` |
| `scripts/test-check-goal.rb` | `aa06386ee2b7f66fe1fad8ffe68dd935df349da796ca2b6f4314cfa56bda552a` |
| `templates/goal/slices.yaml` | `ced3c117f047d8737bd1d1cdc181fa5a4328b96f4a0ec9e68c05f069f3c2412e` |
| `templates/goal/status.yaml` | `d8f382f3ebdaa6b368bf5c5a2c1ef800aeff15dc33c881d41b4110b11f33558b` |
| `evals/workflow-v2/checker.md` | `dee808dc2034e7753927fa8aff0fd33041030aa6fe755295f36d06c9c5c6c2d1` |

独立探针：`/tmp/revision-checker-probes.rb`，SHA-256 `8532fd7d286918fe50c54aa7068b5583e3556135c7ef3f714bc38bb2cbfa80da`。

## 发现

### F1 — P1：没有有效证据来源的待复验验收项仍能显示通过

- 位置：`scripts/check-goal.rb:332–334`、`:407–430`；契约：`evals/workflow-v2/checker.md:69`。
- 触发：先让 S01/B01/A01 验收通过，再把 S01 改为 `awaiting_revalidation`、B01 改为 `pending`，保留实现报告，A01 仍为 `passed`。没有其他已验收且当前有效的批次证明 A01。
- 实际：`Checker#run` 返回 true；`test_reopened_consumer_must_reset_passed_acceptance` 按期望拒绝断言失败。
- 原因：待复验分支只要求所属批次 pending，未核实 `passed` 的有效来源；验收状态检查只有枚举与 accepted 批次必须 passed 的单向约束。
- 影响：失效验收仍显示通过，误导进度及恢复判断。完整 Goal 仍因 awaiting 任务不能 complete，因此不要把此问题夸大为直接绕过最终完成门禁。

**建议的最小修复语义（已与主线程讨论）**：

针对存在 awaiting 任务的批次所映射的验收项，`passed` 必须由另一个 `kind != final`、`state == accepted`、当前快照没有变化的批次证明；无此来源时要求 pending。final 只汇总，不独立贡献证明；不能用 final 的覆盖豁免来把过时中间批次当成当前有效证明。

此语义必须在文档中说明：一个 A-ID 是完整验收断言，passed 表示仍有有效证明，不表示全部映射任务完成。多个批次把不同局部结果冒充同一个 A-ID 是映射错误，需要依据真实标准调整，不得仅为绕过检查机械拆 ID。完成条件仍要求全部任务/批次验收。

**不要采用的过度修复**：

- 不能要求所有 pending 批次的验收项都 pending；合法模板的 final 待审时共享 A01 可以已通过。
- 不能不分证据来源强制所有 awaiting 关联 A-ID 为 pending：若其他有效批次仍证明同一断言，会让共享 A-ID 的恢复互相阻断。
- 只把测试 fixture 拆成独立 A-ID，并不能证明共享恢复仍合法。

应补用例：无其他有效来源拒绝；另有当前有效非 final 来源时允许；只有 final 或已过时来源时拒绝；真实基础返修→基础恢复 accepted→消费者仍 awaiting→进入复验的完整合法路径。

### F2 — P2：模板可预填通过结果

- 位置：`scripts/check-goal.rb:293–296`；契约：`evals/workflow-v2/checker.md:42`、`templates/goal/status.yaml` 的 pending 默认值。
- 触发：任务均 todo、批次均 pending，单独将 A01 改为 passed，按 `template: true` 检查。
- 实际：返回 true；`test_template_cannot_prefill_passed_acceptance` 失败。
- 影响：可复制的模板带上未发生的验收结果；与“模板不允许预填已验收结果”不一致。
- 最小方向：template 分支明确要求所有 acceptance 值为 pending。无需收紧普通执行过程的 pending 批次语义。

## 实际命令与结果

工作目录均为候选根目录，除非明确写绝对路径。

| 命令 | 实际结果 |
| --- | --- |
| `ruby scripts/test-check-goal.rb` | exit 0；seed 17714；44 runs, 138 assertions, 0 failures, 0 errors, 0 skips |
| `ruby scripts/check-goal.rb --template templates/goal` | exit 0；结构、状态与快照检查通过 |
| `ruby /tmp/revision-checker-probes.rb --name '/RevisionReviewerProbes#/'`，最初 7 项版本 | exit 1；7 runs, 13 assertions, 2 failures, 0 errors；F1/F2 |
| 同一探针文件扩展至 11 项后，同命令 | exit 1；seed 57803；11 runs, 24 assertions, 2 failures, 0 errors, 0 skips；仍只有 F1/F2 |
| `shasum -a 256 scripts/check-goal.rb scripts/test-check-goal.rb templates/goal/slices.yaml templates/goal/status.yaml evals/workflow-v2/checker.md /tmp/revision-checker-probes.rb` | exit 0；候选 5 文件与审查开始摘要一致，值见上表 |

计数关系：最终 11 项包含最初 7 项，不能相加为 18 项。探针继承候选测试类以复用 setup、临时仓库、accept、自测报告等帮助器，重写 runnable_methods 并用类名过滤，只执行本次新增方法；没有把父类原 44 项再次算入这 11 项。原 44 项是候选回归，本次 11 项是补充结构/状态反例，两类都不能当成真实业务功能测试数量。

## 亲自核对的覆盖

- 原测试实际覆盖：同批次 implemented 依赖、跨批次/foundation accepted 依赖、任务/批次双向映射、任务及批次循环、基础批次内部等待、快照新增/删除/内容/链接目标/执行位、范围与本批次定义变化、独立批次代码和独立任务追加、上游输入投影、返修状态与执行门禁、旧 JSON/旧范围显式迁移、最终差异与契约、限定排除路径、运行记录排除、CLI 输出目录。
- 本次补充通过：删除明确登记契约；独立批次的契约及任务定义修改不使首批次失效；三级递归依赖的上游变化使第三批次失效；范围内新增已提交文件失效；范围内执行位变化失效；相关契约恢复到 baseline 内容仍使旧批次失效。
- 状态边界：共享 A-ID 设 pending 后，仍持 accepted 的批次会被现有检查拒绝；不同真实 A-ID 可保留上游通过并进入下游复验。另试验单任务 per_slice→functional_batch 切换未造成无关代码失效，此处只确认结构行为，不宣称完成了语义迁移审计。
- 文档一致：源码/契约路径前缀、递归前置批次、非 final 投影、final 全差异+注册契约、可选 review-policy、符号链接只摘要链接文本、旧快照迁移及其语义局限与代码大体一致；待复验验收状态的描述需按 F1 收口。

## 覆盖局限与复审范围

- 没有读取其他通过报告或依赖实现者总结；本报告不确认主线程自身 Goal 的验收真实性。
- 使用候选 fixture 帮助器可以降低配置噪声，但也继承其简化模型：报告内容是占位文本，不能证明真实验证、CR 独立性或有效业务验收。
- 没有穷举所有文件系统/Git 平台差异、并发修改、submodule、clean filter、稀疏工作树等场景；未将未验证设想列为缺陷。
- 声明范围是否漏掉业务真实依赖、实际报告有没有证据、最终审查是否确实覆盖后续修复，仍需人工核对；文件存在和摘要匹配不替代语义审计。
- 本报告仅适用于上列 SHA-256。修复后应重跑 F1/F2 和有效共享证明/失效证明/恢复路径；随后核对模板与迁移说明同步。无需因此重审整个规则库。

---

# 修复后的定向复核（最终结论）

## 结论与发现关闭

**F1、F2 在下列修订版本均已修复。本次定向复核未发现阻塞问题。** 初轮两个失败与原始版本摘要保留在前文，不代表最新版本仍有这两项问题。

- F1：检查在快照新鲜度计算后核实待复验验收项的有效来源。只有其他非 final、accepted、且自身快照当前有效的批次可以保留共享 A-ID 的 passed。final 覆盖、过时批次、in_review 批次均不能替代该来源。
- F2：template 分支明确要求全部 acceptance 为 pending。
- 共享恢复：已亲自验证从原先全部验收通过，经过基础修改、相关批次退回 pending、消费者保留 awaiting、A01 pending，到基础重新 accepted/A01 passed、消费者仍 awaiting，再进入复验并最终完成。**没有要求为通过测试拆分原共享 A-ID，也没有出现相互等待死锁。**
- 完成门禁仍拒绝 awaiting 任务，即使另一个有效批次支持共享 A-ID，不能借此宣布整个 Goal 完成。
- `templates/goal/status.yaml` 与 `evals/workflow-v2/checker.md` 已同步“完整断言由有效批次证明”的口径；未把所有 pending 批次或所有共享 awaiting 一刀切为 pending。

## 最新固定版本

本轮开始与所有定向探针完成后核对，下列摘要一致：

| 文件 | SHA-256 |
| --- | --- |
| `scripts/check-goal.rb` | `af2e1092a81a74ace952b3677174912124f4aa5e62400fa8ed0be9c55cd8a8ca` |
| `scripts/test-check-goal.rb` | `8fda798544eca038af4ca25dfb1e380372dd6d3e90921f4ce9791d01d8e777df` |
| `templates/goal/slices.yaml`（未改变） | `ced3c117f047d8737bd1d1cdc181fa5a4328b96f4a0ec9e68c05f069f3c2412e` |
| `templates/goal/status.yaml` | `e942182d7a25f83fc4b80c328450755b17cdca66353e35a7c75f52872f06bdb4` |
| `evals/workflow-v2/checker.md` | `a636074b9a0872d1a5c1acca4f09c47c2a263251a15e80e42f9316c81e58b510` |

探针版本：

- 原 11 项脚本 `/tmp/revision-checker-probes.rb` 未修改，SHA-256 仍为 `8532fd7d286918fe50c54aa7068b5583e3556135c7ef3f714bc38bb2cbfa80da`。
- 新边界脚本 `/tmp/revision-checker-fix-probes.rb`，SHA-256 `6152db11196df98274a83648453b011d1caad16a98aa8d8c26a85dd057a48f28`。

## 亲自执行的命令与结果

1. 原独立探针原样复跑：

   ```bash
   ruby /tmp/revision-checker-probes.rb --name '/RevisionReviewerProbes#/'
   ```

   exit 0；seed 46095；**11 runs, 24 assertions, 0 failures, 0 errors, 0 skips**。初轮同一脚本中的 F1/F2 从失败转为通过。

2. 本轮新增边界探针：

   ```bash
   ruby /tmp/revision-checker-fix-probes.rb --name '/RevisionFixReviewerProbes#/'
   ```

   exit 0；seed 35253；**4 runs, 18 assertions, 0 failures, 0 errors, 0 skips**。

   具体覆盖：

   - 共享 A01 的完整返修与恢复顺序，包括基础重新 accepted 后消费者仍 awaiting 的中间状态。
   - 同一待复验批次关联 A01/A02 时，A01 有证明不能代替 A02 的证明；A02 改 pending 后可继续。
   - in_review 的批次即使快照未变化，也不能证明共享断言已验收。
   - 另一个当前有效批次证明共享 A01，仍不能让 awaiting 任务所在 Goal complete。

3. 候选修复新增回归的定向执行：

   ```bash
   ruby scripts/test-check-goal.rb --name '/test_(template_cannot_prefill_passed_acceptance|awaiting_revalidation_cannot_keep_passed_acceptance_without_valid_source|shared_acceptance_can_remain_passed_when_another_current_batch_proves_it|final_coverage_alone_cannot_keep_awaiting_acceptance_passed|final_coverage_does_not_make_stale_batch_a_valid_shared_acceptance_source)$/'
   ```

   exit 0；seed 38154；**5 runs, 15 assertions, 0 failures, 0 errors, 0 skips**。亲自阅读对应新增测试及返修旧测试中的状态调整后运行，包含 final-only 来源拒绝、final 覆盖过时来源仍拒绝。

4. 模板与固定版本核对：

   ```bash
   ruby scripts/check-goal.rb --template templates/goal
   shasum -a 256 scripts/check-goal.rb scripts/test-check-goal.rb templates/goal/slices.yaml templates/goal/status.yaml evals/workflow-v2/checker.md /tmp/revision-checker-probes.rb /tmp/revision-checker-fix-probes.rb
   ```

   均 exit 0；模板检查通过；摘要见上表。

## 数量关系与边界

- 原 11 项复跑是同一组回归，不能与初轮的 11 项或它的 7 项前身相加为新覆盖。
- 新 4 项与原 11 项均继承候选测试类，只复用 fixture 与帮助器；每个探针类覆盖 runnable_methods 且执行按类名过滤，未把父类测试再次运行或计数。
- 候选新增 5 项是候选完整测试集的子集，不能与主线程稍后运行的完整 49 项相加。**本轮我没有重跑全 49 项，也没有把主线程或实现者提供的整合结果写成亲自执行结果。**
- 没有重审无变化快照核心、全库流程或业务行为；此次关闭依据是原反例、修改代码/契约、共享状态完整恢复和必要反向边界。初轮关于文件系统、报告语义及真实业务证据的覆盖局限继续有效。
- 没有编辑候选或原仓，没有安装或真实仓库提交；仅新增 `/tmp` 探针并追加本报告。

## 可归档证据文件

以下日志从本次工具实际返回的 stdout 原样保存，**是原执行输出的保存副本，没有再次运行，也没有额外增加测试次数**；对应退出码见上述命令结果。

| 内容 | 路径 |
| --- | --- |
| 初轮与修复复跑共用的原 11 项探针 | `/tmp/revision-checker-probes.rb` |
| 初轮 11 项、2 失败的原输出副本 | `/tmp/revision-checker-probes.initial.run.log` |
| 修复后同一 11 项通过的原输出副本 | `/tmp/revision-checker-probes.fixed.run.log` |
| 本轮新增 4 项边界探针（4 项写在同一个脚本中） | `/tmp/revision-checker-fix-probes.rb` |
| 新 4 项、18 断言全部通过的原输出副本 | `/tmp/revision-checker-fix-probes.run.log` |

最新版本表已包含本轮修改注释的 `templates/goal/status.yaml`：SHA-256 `e942182d7a25f83fc4b80c328450755b17cdca66353e35a7c75f52872f06bdb4`。
