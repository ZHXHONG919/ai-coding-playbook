# 任务拆解首稿执行夹具

这是用于检验“方案→任务→Goal交接”的虚构项目输入，不是业务项目实施。复用docs/examples/plan-output的需求v1、项目现状和方案v12；本夹具另提供可操作原型v3和实际固定图片，不复用已有任务答案。项目技术边界为管理端、单体审核服务和PostgreSQL，无真实业务实现或数据库需要操作。

入口：[执行请求](request.md)、[本夹具采用记录与UI Flow](adoption.md)、[原型](prototype/index.html)。原型与图片只约束明确列出的界面部分；业务数据、权限、去重、异步执行、恢复、保留等仍由原方案负责，演示按钮不能搬进产品。

原型捕获工具复用本机已有Node/Playwright及Chrome，无登录、联网安装、付费或数据库操作。capture.cjs执行本地file原型并向新候选目录保存5个真实状态，逐张打开检查后按adoption记录在夹具内固定。此处“采用”只表示测试输入冻结，不是假称真实用户签收，也不为实际业务批准任何新设计。

全新执行者仅接收request和其中来源，不读取其他eval判据、已有任务案例/回放或本轮CR结论。输出仅允许写runs/<本轮>/下的任务与教学Goal交接包；不启动实际业务、创建App Goal或修改来源。评价者另存评价，不向首稿执行者透露。

重现捕获：在已具备playwright的Node环境，设置NODE_PATH为包目录，运行node capture.cjs <尚不存在的候选输出目录>。目录已存在时直接拒绝，不覆盖prototype/images中的固定图片；候选图需另经检查和采用才能成为新版本基准。脚本使用本机Chrome；可用PLAYWRIGHT_CHROME_PATH指定现有可执行文件，不自动安装。

教学Goal可用 `ruby verify-image-sources.rb <goal.yaml路径>` 自查本输入的5张固定图是否直接列入user_result来源。它只验证图片来源覆盖，不替代模型/用例、实际依赖或业务审查；不会改写Goal或图片。
