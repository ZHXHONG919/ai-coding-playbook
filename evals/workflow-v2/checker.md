# Goal 结构和快照检查

## 能检查什么

- 第二版字段、状态枚举、任务依赖、批次等待环、基础批次内部等待和批次双向映射。
- 同批次普通任务可以依赖 `implemented`；跨批次与基础依赖必须 `accepted`。
- 允许独立任务同时 `in_progress`；主线程焦点以外的进行中任务必须有实现 worker，且与任务所有者声明一致。活动 worker 登记标识、任务、running/stale、仓库相对写入范围；范围不能相同或互为父子，失联范围查实释放前仍占用。
- `single_slice` 限制进行中及仍持有写权限的任务合计为一个，允许任务内部多个 worker；旧串行包可省略或留空 `active_workers`。
- 上游失效而下游半成品失联时，任务用 `awaiting_revalidation` 保留真实部分实现记录，stale 保留写权限；查实停止并核对产物后可移除 worker，任务仍待恢复。恢复 in_progress 前仍须满足原依赖，不能以 stale 放行继续执行。
- `implemented` / `accepted` 有非空实现与自测记录；`awaiting_revalidation` 保留已有全部或部分改动的实际记录，不代表完成或自测通过，不能满足执行依赖，所属批次必须 `pending`。待复验关联的验收若仍为 `passed`，必须由另一个当前快照未过时的非最终已验收批次证明。
- 模板的任务、批次和验收分别只能预填 `todo`、`pending`、`pending`，不能提前声明通过。
- 非最终批次在明确范围内检查新增、删除、内容、可执行位及符号链接目标变化；无关批次代码或新增任务定义不使它失效。
- 前置批次的代码、相关契约与任务定义也属于消费者快照输入，上游变化会使消费者旧证据过时。
- 最终快照覆盖基线到当前全部差异、未跟踪文件、删除文件、核心契约及所有批次已注册的契约。
- 完成状态不含待做/待复验任务、未通过验收、未审批次、阻塞或活动 worker。

文件存在与哈希一致不能证明报告内容真实、测试有效、审查独立或业务验收成立。主线程仍须审计报告、实际行为和影响域。结构检查通过不能写成行为回归通过。

写入范围检查只比较已声明路径，不提供进程锁，也不能发现主线程或未登记进程的越界写入。派工、恢复和接管仍须核实实际执行位置、符号链接及工作区归属，规则见 `skills/goal-execute/SKILL.md`。

## 声明批次范围

在 `slices.yaml` 每个批次声明 `snapshot_scope`，路径均相对 Git 仓库根目录：

```yaml
review_batches:
  - id: B01
    kind: foundation
    # 其余任务映射、验收等字段照常填写
    snapshot_scope:
      paths: [src/permissions, tests/permissions] # 文件或目录前缀，不使用 glob
      contracts: [docs/features/example/permissions.md]
  - id: FINAL
    kind: final
    snapshot_scope:
      contracts: [] # 可再补不属于任何中途批次的相关契约；不能设置 paths 缩小范围
```

非最终批次的 `paths`、`contracts` 均不能为空。源码范围应覆盖实际改动及依赖的稳定代码；相关契约应包含所依据的需求、接口或采用的原型文件。目录会重新枚举其全部已跟踪和未忽略的未跟踪文件，包括基线中已经删除的文件，因此新文件不会因首次快照未列出而漏检。符号链接记录链接目标文本；若目标内容也是执行输入，应把目标文件或目录列入范围。

检查器自动纳入递归前置批次的范围与契约，并对这些批次的任务、依赖和验收映射做结构摘要；整份 `slices.yaml` 不作为中途快照的默认哈希输入。追加完全独立的任务不会使已有批次失效，修改本批次或前置批次定义则会。存在 `review-policy.md` 时，各批次自动纳入。

主线程负责选择业务上相关的契约。脚本不能识别未声明的共享代码、其他文档中的口径变化或漏掉的原型资产；发现遗漏必须补充范围并按影响复验，不能等最终检查兜底。跨批次共用一份需求文件时，可以直接登记整份文件并接受保守失效；只有确有稳定独立契约才分别登记，不为减少哈希变化拆碎文档。

## 命令

```bash
# 模板允许未填写的基线提交，但不允许预填已实现/已验收结果。
ruby scripts/check-goal.rb --template templates/goal

# 项目 Goal 只读检查，需要真实完整基线提交。
ruby scripts/check-goal.rb docs/features/example/.goal

# 检查脚本回归，在临时 Git 仓库运行，不碰真实项目状态。
ruby scripts/test-check-goal.rb

# 候选规则库检查，不读取全局安装链接、不安装。
bash scripts/check-playbook.sh --repo-only

# 固定当前批次版本；基线、范围和允许排除项都从 Goal 读取。
ruby scripts/check-goal.rb --snapshot-batch docs/features/example/.goal B01 \
  docs/features/example/.goal/snapshots/B01.json

# 最终仍使用同一个命令，自动覆盖全部差异和契约。
ruby scripts/check-goal.rb --snapshot-batch docs/features/example/.goal FINAL \
  docs/features/example/.goal/snapshots/FINAL.json
```

先固定待验证与审查的代码范围；采集与审查期间不要继续修改该范围。两份报告引用同一清单和覆盖范围，主线程核对后才更新 `status.review_batches.<id>.snapshot` 与验收状态。命令只写指定 JSON，不执行测试、审查、Git 提交或业务修改；输出必须在当前 Goal 的 `snapshots/` 内，目录预先存在。

仅自动排除当前 Goal 的 `status.yaml`、`resume.md`、`execution-log.md`、`runs/`、`validation/`、`cr/`、`snapshots/`。其中 `execution-log.md` 是可选的执行分析记录，不作为验收契约；其他目录中的同名模板或流程规则仍进入最终差异。不得排除业务源码或相关契约。

## 返修与迁移

上游基础返修后，相关批次改为 `pending`；下游已有全部或部分改动进入 `awaiting_revalidation`，保留原记录，补充实际完成/未完成、已测/未测、产物核实与恢复条件。受影响验收项若没有其他当前有效的非最终已验收批次证明该完整断言，回到 `pending`。该状态不表示实现完成或旧自测仍有效。前置条件恢复后，从 `next_slice` 指向的待恢复任务进入 `in_progress`，补完实现并按影响范围复验；达到本任务完成和自测标准后回到 `implemented`，再次批次验收。不需要丢掉已有改动退回 `todo`，也不能在依赖未恢复时恢复执行。

`acceptance.<A-ID>: passed` 表示至少一个当前有效的非最终已验收批次证明该完整断言，不表示所有映射任务已完成。多个批次共用同一完整断言时，上游重新验收有效后可以把它标为 `passed`，消费者仍保留 `awaiting_revalidation`，随后按依赖恢复执行；不能因消费者待复验而强制上游同步失效。最终批次或被最终覆盖但自身快照已过时的旧批次，不能充当此处的有效来源。若多个批次实际只证明一个断言的不同部分，应拆成真实独立验收断言；不能为了通过检查任意拆分或借共享 ID 宣称尚未验证的结果通过。

当前快照 JSON 使用 `schema_version: 2`；Goal YAML 仍为第二版，增加 `snapshot_scope` 与待复验任务状态。已有快照或缺失范围的旧批次不会静默通过：核实原报告实际覆盖范围，补齐声明，对遗漏或变化定向复核后重新采集。仅重写哈希不能算复验。旧 `--snapshot 仓库 基线 输出 --exclude ... --contract ...` 仅保留为第一版全仓内容清单工具，其结果不能直接当作当前 Goal 批次验收。

已验收范围发生变化，必须定向复验复审；最新最终批次也可以明确覆盖之前批次的后续变化。最终覆盖必须实际核对受影响部分，不能只更新快照路径或因结构检查通过而宣布业务通过。
