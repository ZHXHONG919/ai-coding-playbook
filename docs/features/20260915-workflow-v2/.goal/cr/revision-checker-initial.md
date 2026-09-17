# 固定候选检查器独立审查

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
