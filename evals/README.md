# Playbook Evals

> 目标：用可复查样例验证 playbook 规则、skill 路由和输出门禁是否真的改善 agent 行为。

## 目录约定

```text
evals/
  <skill-or-stage>/
    <case-name>.md
```

每个 eval case 至少包含：

- `Prompt`：给 agent 的输入。
- `Expected Route`：应该触发的 skill、stage 或 reference。
- `Must Include`：输出必须包含的结构或判断。
- `Must Not`：禁止出现的行为。
- `Regression Notes`：人工复查或后续自动化检查要点。

## 评测原则

- 评测真实输出，不只评测规则文件是否存在。
- 优先写确定性检查项，例如必须区分 `Confirmed / Pending / Assumed`，必须列测试命令，必须给出 Go / No-Go。
- 不用另一个模型做最终裁判；模型可以辅助总结，但通过与否应由明确检查项决定。
- 改 skill description、阶段路由、模板或门禁后，补充或更新至少一个对应 eval。

## 当前状态

本目录先提供人工可执行的基线样例。后续可以增加脚本，把 `Must Include` / `Must Not` 转成自动检查。

## v2 可执行检查与独立行为回放

- `ruby scripts/test-check-goal.rb`：临时Git仓库中的状态、依赖、报告引用与内容快照正/负例。
- `ruby scripts/check-goal.rb --template templates/goal`：模板结构一致性，不能代替真实Goal Ready。
- `evals/workflow-v2/*/input.md`：独立 Agent 只读输入和候选规则，先实际回答，再由另一方使用 expected.json 评分；不把答案泄漏给执行者。
- `evals/workflow-v2/execution/upload-preview/`：复制到隔离目录实际修复控制器，用未提供给实现者的用户行为检查复核；明确这不是浏览器或真实项目验收。

仓库自检、结构检查、行为回放和真实项目交付质量是不同层次。一次回放结果不能外推耗时/token收益。
