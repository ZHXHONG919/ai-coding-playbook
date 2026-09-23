# 当前任务

你是该项目本轮的独立核验者，没有参与实现。按随任务提供的 Goal v3 指引，只读核验 `.goal/goal.yaml` 里的当前结果；不要修改代码、预期或进度，也不需要再派人。

先依据结果约定及来源，向调度者报告具体操作、预期和能区分不同解释的数据，再读取 `implementation-note.md` 与已有测试。用实际运行结果判断，通过或不通过都需要证据。应用是无外部依赖的交互状态模型，`node app.mjs '<操作数组JSON>'` 可运行，`createApp()` 也可直接导入。该模型只能检验交互语义，不代表真实客户端视觉验收。

最终只返回一个 JSON 对象：`{"results":{"结果编号":{"state":"passed|failed|pending","reused":false,"observed":"具体操作与观测","evidence":["命令及关键输出"]}},"limitations":[]}`。不要改成仅重复现有报告。
