# 图稿与复现

`architecture`、`use-cases`、`domain`、`execution-state`、`schema` 及两张分表图 `schema-batch`、`schema-item` 保留 Graphviz `.dot` 源、SVG 与 PNG。`sequence` 实际为泳道图，由 `generate-diagrams.cjs` 的 `swim()` 生成 SVG；文件名仅用于本示例引用。

本机实测采用内置 `@viz-js/viz`（Graphviz WASM）离线排版、Playwright 调用 Chrome 栅格化。环境变量指定依赖路径，不要求安装全局 CLI：

```sh
DIAGRAM_NODE_MODULES=/path/to/node_modules CHROME_PATH=/path/to/chrome node generate-diagrams.cjs
```

依赖目录必须含 `@viz-js/viz` 与 `playwright`。不设置 `CHROME_PATH` 时使用 Playwright 自带浏览器。

Graphviz 中文字宽存在度量偏差，本示例对生成 SVG 的字号作补偿，并实际打开 PNG 检查。该补偿是本环境处理，不是通用图稿标准。SVG 为放大阅读源，PNG 为 Markdown 稳定预览。泳道图采用专用 SVG 是当前环境的示例实现，不要求所有后续方案手工绘图。

生成脚本包含图定义；改图后从脚本重新生成，避免直接编辑导出的文件。当前图稿未上传外部服务。
