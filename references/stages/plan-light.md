# 轻量方案入口

这是统一方案准备的轻量入口。范围判断沿用 `references/stages/plan.md`；实际编写方法统一放在 `references/plan/plan-light-writing-guide.md`，本入口不再维护另一套成文步骤。

## 取得完整轻量方法，再开始本轮设计

采用已取得的项目约定和明确规则根，在选定根读取light方法包：

```sh
python3 <选定根>/scripts/read-plan-context.py method --root <选定根> --mode light
```

这一包返回根AGENTS、统一plan阶段、本入口、轻量编写方法、证据方法及轻量模板的实际全文。已有这些同版正文完整返回时直接复用；否则先完成这一步，截断按统一阶段的方法补齐。

已有文件工具也可等价取得同一组完整正文，不要求为准备安装Python。项目约定与方法准备可按明确先后在同一有序输出组取得；全部方法实际完整返回后，再单独开始具体业务定义的发现和细读。文件名称清单可复用，不能将补方法与读取业务定义合成一步。

方法包完整取得后，按 `references/plan/plan-light-writing-guide.md` 编写，使用 `templates/plan-light.md` 呈现。只做本次轻量范围，不因共用准备而加载完整八章写法。
