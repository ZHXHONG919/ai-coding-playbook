---
name: codegen-doc
description: Generate or refresh engineering documentation from repository facts. Use for project overviews, module documentation, technical handoff notes, key issue summaries, implementation notes, or README-style docs based on current code.
---

# Codegen Doc

## 使用时机

- 根据当前项目或代码生成项目说明、模块说明、交接文档、技术难点、实现说明。
- 更新 README、docs、方案文档或 PR 背景说明。
- 从代码、配置、测试和已有文档中整理现状，不做功能实现。

## 文档类型

| 用户意图 | 输出 |
| --- | --- |
| 项目梳理、项目介绍 | 项目概览、技术栈、模块边界、启动/验证入口 |
| 模块说明、交接 | 目标、入口文件、核心流程、数据模型、关键风险 |
| 技术难点、重点问题 | 问题清单、影响面、已有处理、待改进项 |
| 实现说明、PR 背景 | 变更动机、方案摘要、影响面、验证方式 |
| README 更新 | 面向使用者的安装、运行、配置和常见问题 |

## 生成流程

1. 先读项目本地文档：README、AGENTS、CLAUDE、docs。
2. 按用户目标读取相关代码和配置；不要全仓库无差别总结。
3. 抽取事实并标注来源：
   - 文档事实。
   - 代码事实。
   - 配置事实。
   - 推断或待确认。
4. 选择面向读者：开发者、Reviewer、接手同事、发布负责人或非技术读者。
5. 按目标文档组织，不把所有发现都塞进正文。
6. 如果用户要求落盘，先确认目标路径；否则默认只输出正文。

## 写作要求

- 不编造不存在的模块、指标、接口或发布流程。
- 保留项目原有术语，避免同一概念多个名字。
- 对风险和未知项明确标注“待确认”。
- 文档应可维护：标题清楚、列表短、代码路径可定位。
- 不写真实凭据、内部 token、客户数据。

## 输出

```markdown
## 文档正文

## 证据来源

## 待确认
```
