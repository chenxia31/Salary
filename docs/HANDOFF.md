# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-06 · by antigravity · 对应 commit：`feat(app): 实现macOS状态栏每秒薪资流速与Apple HIG看板`

---

## 一、现在做到哪了

核心功能完整实现并通过所有预检与单元测试。
应用支持：
1. 月薪输入与自定义法定计薪天数（默认21.75天），支持上下班与午休时间配置。
2. 状态栏每秒平滑无抖动跳动（4种显示模式：今日已赚、每秒流速、紧凑金额、仅图标）。
3. Apple HIG 原生毛玻璃弹窗看板：巨幅金额实时跳动、三联流速卡片（秒/分/时）、工时进度条与下班倒计时、打工人趣味里程碑勋章。
4. 100% 纯逻辑 Swift Testing 单元测试全绿，`preflight.sh` 检查全绿。

## 二、这一棒做了什么

- 初始化项目结构并对齐 `iOS-app-sets` 规范（AGENTS.md、CLAUDE.md、GEMINI.md、DECISIONS.md、preflight.sh）
- 编写功能规格 `specs/salary-status-bar.md`
- 实现 `Core/Calculation/SalaryEngine.swift` 与 10 项 Swift Testing 单元测试
- 实现 `Core/Storage/SalarySettings.swift` 与 UserDefaults 持久化
- 实现 `Features/StatusBar/` 状态栏视图与每秒定时驱动（防抖动等宽数字）
- 实现 `Features/Dashboard/` Apple HIG 质感弹窗看板（Hero卡片、流速卡片、工时进度、打工人里程碑）
- 实现 `Features/Settings/` 偏好设置面板与快捷月薪调整
- 实现 `App/SalaryTickerApp.swift` 与 `.accessory` 纯状态栏应用生命周期
- 配置 `Package.swift` 与 `project.yml` (xcodegen)，验证 Xcode 工程与 CLI 构建均正常

## 三、下一棒从这里开始

**目标**：根据需要打包签名 Release 产物或丰富更多趣味里程碑/音效反馈。

**入口**：
- 双击运行 `SalaryTicker.xcodeproj` 或执行 `swift run SalaryTicker`

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 已完成 | 核心功能均已完备且通过测试 |

## 五、待人工决策

- [ ] 是否需要自定义应用 AppIcon 图标素材替换默认系统 SF Symbol 图标

## 六、踩过的坑 / 别再试的路

- 状态栏必须使用 `.monospacedDigit()`，否则每秒数字变化时宽度微颤会影响视觉体验。
- Swift 6 中 `@MainActor` 类的 `deinit` 必须配合 `@ObservationIgnored` 与 `nonisolated(unsafe)` 管理后台 `Task`，否则触发严格并发编译报错。
- `project.yml` 中内部模块使用 `library.static`，避免嵌入 framework 引起的 ad-hoc 代码签名失败。

## 七、环境与验证

- 自动化检查：`./scripts/preflight.sh`（全绿）
- 编译与单测：`swift test`（10 tests passed in 0.008s）
- Xcode 工程：`SalaryTicker.xcodeproj`（Build Succeeded）
