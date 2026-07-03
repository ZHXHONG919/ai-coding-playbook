# pnpm Monorepo 场景规则

> 通用 pnpm workspace 约定。包名、脚本、目录以目标业务项目文档为准；这里只提供跨项目判断标准。

## 适用时机

- 分析或实现涉及多个 package 的改动。
- 推导测试范围、构建顺序、共享 types/utils 影响面。
- 设计 API、前端、extension、共享包之间的边界。

## 先读什么

1. 目标项目 `README.md`、`AGENTS.md`、`package.json`、`pnpm-workspace.yaml`。
2. 确认 workspace 包名后再写 `pnpm --filter` 命令，不编造包名。

## 常见结构

```text
repo/
├── package.json
├── pnpm-workspace.yaml
├── code/
│   ├── server/        # NestJS API
│   ├── admin-web/     # React + Vite
│   ├── ops-web/
│   └── shared/        # types, utils（如有）
└── deploy/
```

具体目录名因项目而异，以项目事实为准。

## 命令原则

- 优先最小 `--filter`，不要默认跑全仓库 test/build。
- 共享包变更时，列出可能受影响的下游包测试。
- 发布脚本、migration、env 变更单独归类，不与普通 package test 混为一谈。

```bash
pnpm --filter <package> test
pnpm --filter <package> build
pnpm --filter <package> lint
```

## 影响面判断

| 变更位置 | 通常影响 |
| --- | --- |
| `code/server` | API、e2e、migration、deploy |
| `code/*-web` | 对应前端 build/test、浏览器 smoke |
| `code/shared` 或公共 types | 所有引用方 package |
| `deploy/` | release script、shellcheck、dry-run |
| extension / collector | 扩展 build、加载 smoke、上报链路 |

## 设计约束

- 共享 types 只放稳定契约；不要把业务临时状态塞进 shared。
- 包间依赖方向保持清晰：web → api client；server ↛ web。
- 跨包 breaking change 要同步版本策略或兼容层。
- monorepo 不等于所有改动都要全量发布；发布 targets 仍以项目发布文档为准。

## 与 playbook 的配合

- API 设计：配合 `skills/nest-api-design/SKILL.md`。
- 前端：配合 `skills/react-vite-feature/SKILL.md`。
- 测试范围：配合 `skills/test-scope-analysis/SKILL.md`。
- 全栈场景：配合 `references/scenarios/nest-react-postgres.md`。
