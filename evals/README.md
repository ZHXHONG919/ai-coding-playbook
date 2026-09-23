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

## 当前结构检查与独立行为回放

- `ruby scripts/test-goal-v3.rb`：临时 Git 仓库中的 v3 结果、任务、依赖、增量证据及非法格式正反例。
- `ruby scripts/check-goal.rb --template templates/goal-v3`：当前模板结构一致性，不能代替真实 Goal 的开工条件。
- [共用交付行为场景](delivery-behavior/README.md)：01–14 的 `input.md` 提供给独立执行者；运行后才由评价者读取 `expected.json` 评分，不把预期答案泄漏给执行者。
- `delivery-behavior/execution/upload-preview/`：复制到隔离目录实际修复控制器，用未给实现者的用户行为检查复核；不能称为浏览器或真实项目验收。
- [Goal v3 专用盲测](workflow-v3/README.md)：验证实际入口、界面层级和用户变更后的证据恢复；历史原始结果保存在 `workflow-v3/results/`，保持原样。
- `goal-execute/unsupported-goal-format.md`：旧格式明确不支持，不能替换版本号或把旧状态伪装成当前核验证据。

仓库自检、结构检查、行为回放和真实项目交付质量是不同层次。现行样例的修改不会自动使历史结果代表新版本通过，一次回放也不能外推耗时或 token 收益。
