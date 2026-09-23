# 评测：按用户结果拆 Goal，保留前端模拟到真实集成的依赖

## Prompt

后台功能的 UI Flow 和方案已确认，请拆 tasks 并生成 Goal。用户要完成内容池选择、发布、审核三条路径，每条都有页面和 API；希望先看到交互可用，再逐步接真实服务。

## Expected Route

- `ai-coding-playbook` → 任务拆解 / Goal Handoff。
- 读取 `references/plan/task-breakdown.md`、`references/stages/goal-handoff.md`。

## Must Include

- 先列全三条完整用户结果及共享基础，每条路径一个 owner；正式验收挂在结果上。
- 工程任务按当前需要滚动展开，保留 `CONTRACT → FE_MOCK_LOOP → SERVER_CAPABILITY → MOCK_REPLACEMENT → INTEGRATION / QA` 的实际依赖。
- FE_MOCK_LOOP 覆盖交互、ViewModel、接口边界、符合真实类型的模拟数据及代表页面的原型对照。
- 每条路径尽早走通最小真实入口，逐步扩展状态；模拟替换、真实服务与最终集成结果都仍在范围内。
- 模拟用途、责任、退出条件可追踪；任务只引用结果，不另外维护一套 lane 状态或重复产品预期。

## Must Not

- 在所有页面模拟完成前禁止任何真实集成，或等全功能写完才第一次联调。
- 用功能点分组掩盖共享契约、前后依赖或缺失的真实结果。
- 把页面 mock 通过当成最终用户结果通过。
- Goal Handoff 无依据推翻已确认的交互或任务依赖。

## Regression Notes

检查结果完整性、共享规则依赖与最小真实路径，不能用 lane 标签存在代替判断。
