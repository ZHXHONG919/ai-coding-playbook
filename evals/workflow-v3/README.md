# Workflow v3 验证

分开验证两件事：检查器能否拒绝不完整或过期记录；独立执行者能否据当前用户结果判断真实行为。结构脚本通过不替代第二类验证。

## 可执行行为盲测

`behavior/` 包含两个无依赖 JavaScript 控制场景：入口和页面层级判断；用户变更后的恢复及证据复用。它们不是原业务项目的全量回放，也不能证明真实视觉还原或额度节省。

调度者先准备独立临时项目：

```bash
node evals/workflow-v3/behavior/prepare.mjs all /tmp/workflow-v3-blind-input
```

目标必须不存在或为空。准备器只复制公开输入，建立临时 Git 基线；恢复场景用检查器生成可验证的历史 run 后注入局部用户变更。`behavior/evaluator/` 的评分标准和评分器留在规则仓库，不给执行者读取。不要把真实会话、客户数据或完整业务日志复制到夹具。

使用一个 `fork_turns: none` 的新执行者，发送：

> 只读核验两个独立小项目。先读 `<输出目录>/guide.md`，随后分别执行 `<输出目录>/navigation/request.md` 和 `<输出目录>/recovery/request.md`。按各自请求先报告预期再读取实现报告；可以运行本地命令。不要修改项目，不要再派人。两个项目的最终 JSON 分开返回。工具根目录是 `<候选仓库>`，仅在指引要求时调用其检查器；不要读取规则仓库中的 evals 或评分文件。

调度者将两份最终 JSON 原样保存到临时文件，然后评分：

```bash
node evals/workflow-v3/behavior/evaluator/score.mjs navigation /tmp/navigation-verdict.json
node evals/workflow-v3/behavior/evaluator/score.mjs recovery /tmp/recovery-verdict.json
```

评分器不自动证明独立阅读或证据真实；还须按隐藏 rubric 核对执行者工具轨迹。准备器和夹具语法冒烟不计入行为盲测成绩。策略对比需要另建相同初态输入及无历史执行者，不向后续执行者透露前轮结论。
