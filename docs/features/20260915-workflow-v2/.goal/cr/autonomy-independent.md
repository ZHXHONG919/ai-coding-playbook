# 自主续跑与契约隔离：独立定向复核

## 结论

**在已审范围内未发现阻塞问题。** 这是候选规则的语义一致性复核，不是零缺陷承诺，也不是整个 Goal 的验收结论。

场景 13 的原始盲测回答已原样保存于 `../validation/autonomy-trials/13-result.md`。盲测时仅读取该 input 和三份候选规则，未读取 expected 或历史结果；本轮规则复核开始后才读取场景 13/14 的 expected。

## 覆盖与判断

- 依据 `validation/autonomy-delta.json` 逐项读取候选文件当前内容，并补读 Goal 的 slices/status/gate 模板和 skill-maintenance 审查口径。范围包括入口、中央节点流程、方案/需求确认/实现/Review 阶段、Goal 执行、交接及缺口台账、新增场景与本次执行包；已纳入主线程补同步的 GOAL.md。
- **续跑与局部缺口：** Goal 恢复明确区分首次 Gate 和运行中局部缺口；中央规则要求保留有效证据、重排实际依赖、继续可隔离工作。首次需求/原型确认规则限定于开工前，没有要求已获授权的执行重复整轮问答。
- **协议与真实能力：** 任务拆解、Goal 状态与台账一致要求按责任拆开，并保留真实能力和最终集成依赖。未确定的权限/归属/状态语义不能用接口签名或模拟代替；基础批次须验收后供依赖使用，同批次普通任务可消费 implemented 输入。
- **完成真实性：** 必需下载或读路径不能因 mock、TODO、waiver 或 build 成功而完成；纯环境缺口无需制造占位实现。模板要求记录恢复条件、责任、回收点和真实证据，与中央流程一致。
- **防止意图与视觉漂移：** 交接保留约束原文、真实类型、原型来源、范围和验证边界；实现/修复继续引用采用稿，Reviewer 的便利化或美化建议不能覆盖用户决定。
- **避免重复仪式：** 正式验证/CR 按功能或基础批次执行，证据按实际影响失效；未变化的独立范围可复用。台账按需建立，状态仅有一个执行索引；模板没有要求逐工具、逐节点新建报告或重复批准。
- 本次 GOAL.md、plan.md、acceptance.md 和 slices.yaml 对 D01–D09、候选隔离、行为推演与真实验证的界限一致。新增 expected 与中央规则方向一致，且明确推演不能证明实际效率提升。

## 局限

未运行或重跑测试，未操作业务服务、实际导出、生产环境或安装源；没有核验当前 Goal 的运行状态和验收报告，也没有以本报告宣布任何批次 accepted。对检查器仅核对模板表达，未重新审查脚本实现。此次清单是文件级范围，以下摘要绑定的是实际读取的当前文件内容，不将同文件中全部历史改动冒称本轮新增。盲测仅提供给定场景的判断证据；真实执行中的工具可用性、任务重排和证据回收仍需实际验证。

## 已读取文件 SHA-256

以下在报告落盘时从候选工作树计算；不包含本报告自身。主线程后续修改其中任何文件时，应按影响决定是否复核。

| 文件 | SHA-256 |
| --- | --- |
| `AGENTS.md` | `2e4fc62064b4df8ce1df974ed5c3f906076932fa268619db35f89b3f5dc35389` |
| `README.md` | `08b7a14a36fc3515a93ec55611cdee8e1f94011c01962faeebddfb2e8c0440c1` |
| `docs/features/20260915-workflow-v2/.goal/GOAL.md` | `5917b2f29e317b75b99202952d58cbda16d49d7413135aa6c245d621e0d1272f` |
| `docs/features/20260915-workflow-v2/.goal/acceptance.md` | `9ebaa0f605a628ef5fb1f3690b9dfa6b93a27b8e6c84b7aac89a4ba70bb94766` |
| `docs/features/20260915-workflow-v2/.goal/slices.yaml` | `50bad7c7595b8a26e3d30a7dda64daa9f05cdfa3969f1a338e148f3f58e52595` |
| `docs/features/20260915-workflow-v2/plan.md` | `942f144d1d80915dd9181d2333bd292ba38941be15650afef32782badb2728ea` |
| `evals/goal-execute/no-deferred-final-done.md` | `e800d8fbd765ce57dc3d50ef77c7e04dd75cfc9fec5477d0dce2cf92544dcd53` |
| `references/delivery/agent-delivery-flow.md` | `3b32b61cc79c396d2535992547a5a14203c63bb4f002a39db57638842505744f` |
| `references/delivery/execution-evidence.md` | `59e38889f16e750268256ae3eef510fe4720f87b605439086d91ad8a576a13cc` |
| `references/plan/task-breakdown.md` | `05754e16afba29e7c867c5d2442797917096e70cc0b005e00ecc97662a0b5e43` |
| `references/stages/goal-handoff.md` | `182c224ce5c7d6dbf1f01ba6b6355463781186681059391d01372fe4fddc9a35` |
| `references/stages/implementation.md` | `667230c0a2d2581f152c96e587fd20b9db27d7a55b2379b532db4b836a6e8b3d` |
| `references/stages/plan.md` | `d492e2d79a3c32798d1d4df42a6d110880fb47ac296c262a9d5bce75e6bc91c9` |
| `references/stages/requirement-confirmation.md` | `90a1bf2245b3d1b9e08f653dcc28c4984feb06c88e07e90c9d110e64497d549d` |
| `references/stages/review.md` | `bb2f059d7dd8811e2663f2a78f79acf18b90a6a1463ad3795f55075de3864335` |
| `skills/ai-coding-playbook/SKILL.md` | `6c459caf9434f36113f5ec272f04edca04a7af9a0ee073fd225aa473ee98465a` |
| `skills/fullstack-ui-prototype/SKILL.md` | `2daf9e15f06ac6ff5e317b9fcac6ca22bd9bd73a0fce27634543613ea873fd2d` |
| `skills/goal-execute/SKILL.md` | `5963c2c9ebd6eef90d5ebbb4d924924cafcdc0a69bf96020b552501559e7eab2` |
| `templates/goal/GOAL.md` | `0a3e9b643ba5b8ce10908c9f95d50d9e31ce3dda5118de9254947a0668d75ca1` |
| `templates/goal/design-handoff.md` | `229d3d3474f16ec1dde34ad36223aba8feea62f2be1cafa54bcb4f56ac8d073d` |
| `templates/goal/human-intervention.md` | `f95c4e18aa9d25055c71866bc5d69cab02f60bc9b6e9626ee5f374d18e795279` |
| `templates/goal/risks-deferred.md` | `44c1f8a2d4d84592c503ed03b97708bce3d1b98e56d6424c6610a2070441e2bc` |
| `templates/goal/worker-report.md` | `90a6091ff49773a42825e7dac2fb1bf0ad4a0ca82b0d7bfeef1bcc3cbf81d89a` |
| `evals/goal-execute/local-todo-does-not-block-next-slice.md` | `f4c3e8efa196d60a57cdfe0f5d603982a3dd7afc6fc36a1baa1b3f3f4c8a0071` |
| `evals/workflow-v2/13-autonomous-contract-recovery/expected.json` | `9d3db467bd2a69af1ce2c900e929897ae3d123d3d731ed61f81930899bb86c9e` |
| `evals/workflow-v2/13-autonomous-contract-recovery/input.md` | `f2b2b5c6880fc5d61c9c9575dca8a8f98b96c5df12d40963000b305d8138ffb4` |
| `evals/workflow-v2/14-minimal-handoff-retains-intent/expected.json` | `14efbefb5e36e0dfee98ea113091c2da33ee84788e76e256b857623f89b57e86` |
| `evals/workflow-v2/14-minimal-handoff-retains-intent/input.md` | `cee877d1dd2bc8ffb2a409990290504694402c40c488ba11e205e39108ab43a3` |
| `templates/goal/mock-ledger.md` | `7a4eb3f8b01c2dcca14ec154b8099310596f97d7bb9a00083c8d910445d085e1` |
| `templates/goal/todo-ledger.md` | `b3e331d3667c09cfbe49123f5932ded3364446e45bcb9138628bd4877878571a` |
| `docs/features/20260915-workflow-v2/.goal/validation/autonomy-delta.json` | `0b4d76677bdb935175078a198617b40ab4c09f297b4d48ea99193e2fe0e31a86` |
| `skills/skill-maintenance/SKILL.md` | `86f2014b41987fa0a0cc746062bded382276ea6b0d3f47ac398eef22c15232b6` |
| `templates/goal/slices.yaml` | `ced3c117f047d8737bd1d1cdc181fa5a4328b96f4a0ec9e68c05f069f3c2412e` |
| `templates/goal/status.yaml` | `e942182d7a25f83fc4b80c328450755b17cdca66353e35a7c75f52872f06bdb4` |
| `templates/goal/gate.md` | `6551404f3d920b8cd4e61349a72bc481de08d2dedb8cc41ef1e2c109e45353d1` |
