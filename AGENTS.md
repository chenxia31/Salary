# AGENTS.md

本文件是本仓库面向**所有 AI 编码代理的唯一权威指令源**。
Claude Code 经 `CLAUDE.md` 导入，Gemini CLI 经 `GEMINI.md` 导入。**改规范只改这一个文件。**

## 项目

- 产品：SalaryTicker（时薪）—— macOS 状态栏实时每秒薪资流速与今日收入看板
- 平台：macOS 14.0+ / SwiftUI / Swift 6
- 依赖管理：Swift Package Manager / 原生框架（不引入未经评审的第三方依赖）
- 目录约定：
  - `App/` 入口与依赖装配（`SalaryTickerApp.swift`, `AppDelegate.swift`）
  - `Features/<模块>/` 按功能聚合 View + Model + Store（**不按文件类型分目录**）
    - `Features/StatusBar/` 状态栏常驻项、平滑跳动显示、图标与样式切换
    - `Features/Dashboard/` 下拉主面板（Apple HIG 磨砂玻璃质感、大字动态看板、工时进度、趣味里程碑）
    - `Features/Settings/` 薪资与工时设置、午休设置、计薪规则与偏好设置
  - `Core/` 基础设施与纯计算逻辑
    - `Core/Calculation/` `SalaryEngine` 纯数学计算引擎（日薪/时薪/分薪/秒薪/今日实时已赚）
    - `Core/Storage/` `SalarySettings` 与持久化存储管理
    - `Core/Logging/` `AppLogger` 统一统一日志管理
  - `Resources/` 资源、图标与多语言本地化
  - `specs/` 功能规格　`docs/` 协作文档　`scripts/` 自动化

## 开工前必做（每个 session，按顺序）

1. 读 `docs/HANDOFF.md` —— 上一棒的交接状态，这是你的起点，不要跳过
2. `git status && git log --oneline -10` —— 确认工作区干净、了解最近改动
3. 任务在 `specs/` 有对应文件就先读；**没有、且预计改动 > 50 行 → 先写 spec 再写代码**

## 收工前必做（每个 session，不可跳过）

1. 跑 `./scripts/preflight.sh`，全绿才算完成
2. `git commit`（格式见下）—— **不允许把未提交的改动留给下一棒**
3. 覆盖式重写 `docs/HANDOFF.md`
4. 有架构级决策 → 追加一条到 `docs/DECISIONS.md`

## Git

**禁止**：`git push -f`、rebase 已推送的分支、amend 已推送的提交、`git reset --hard`、`git checkout .`、`git clean -fd`。
需要撤销已推送的改动 → 用 `git revert`。

- 分支：`main` 始终可发布；`feature/<简述>`、`fix/<简述>`、`release/<版本>`
- 一个提交只做一件事，且能用一句话说清
- 提交信息格式：

```
<type>(<scope>): <中文祈使句，一行>

<可选：为什么这么改。不要复述做了什么，diff 里有>

Agent: claude-code | gemini-cli | antigravity | human
Spec: specs/xxx.md
```

`type` ∈ `feat` `fix` `refactor` `test` `docs` `chore` `perf`

## 代码约定

- Swift 6 严格并发；UI 相关类型标 `@MainActor`
- 视图文件只放视图；业务逻辑放 `XxxService` / `XxxStore`（理由：要能单测）
- 异步一律 `async/await`，不写 completion handler
- 日志用 `Logger`，不用 `print`：
  ```swift
  private let log = Logger(subsystem: "com.openclaw.salaryticker", category: "salary")
  ```
- 强制解包 `!` 只允许出现在 `#Preview` 与测试代码中
- 用户可见文案一律 `String(localized: "key")`，不写字面量
- 状态栏字符杜绝抖动，金额数字必须应用 `.monospacedDigit()`

## 测试

- 纯逻辑（计算 / 解析 / 状态机 / 日期金额）必须有单测，用 Swift Testing：
  ```swift
  import Testing
  @Test func 计算每秒流速准确() { #expect(...) }
  ```
- 改动已有逻辑前先跑现有测试；红的不许提交

## 边界（Never）

- 不手改 `*.pbxproj` / `*.xcodeproj`
- 不提交证书、密钥、`.env`、API Key
- 不引入新的第三方依赖 —— 先在 `docs/DECISIONS.md` 提待决策，等人确认
- 不修改或删除 `docs/DECISIONS.md` 的既有条目（**只追加**）
- 不删测试、不加 `try?` 吞异常来让构建通过
- 不做任务或 spec 之外的"顺手重构"、顺手格式化、顺手升级依赖
- 不在代码里写死任何真实用户数据或密钥

## 不确定时

**停下来，不要猜着实现。** 把问题写进 `docs/HANDOFF.md` 的「待人工决策」，说明：问题是什么、你倾向哪个方案、为什么。
