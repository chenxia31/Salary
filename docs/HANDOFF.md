# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-06 · by antigravity · 对应 commit：`feat(settings): 支持状态栏图标颜色定制、生活目标编辑与30天试用¥1.99付费`

---

## 一、现在做到哪了

完成 3 个新功能交付：
1. **菜单栏图标与颜色定制**：8 款精选图标与 7 种主题色彩（含自适应工作状态色与极简单色）。
2. **生活目标与里程碑自由定制**：支持自由编辑、新增、删除打工小目标（如特调冰美式 ¥32、猫粮基金 ¥80）。
3. **30 天试用与 ¥1.99 商业化机制**：开箱即享 30 天完整试用，到期后通过 Apple 原生 StoreKit 2 支付 ¥1.99 解锁，包含精美 Paywall 弹窗及免沙盒开发测试开关。

## 二、这一棒做了什么

- 更新规格 `specs/salary-status-bar.md`
- 扩展 `Core/Storage/SalarySettings.swift`：增加 `statusIcon` 与 `statusColorTheme`
- 实现 `Core/Storage/SubscriptionStore.swift`：30 天试用倒计时计算、PRO 激活、StoreKit 2 交易监听与测试开关
- 更新 `Features/StatusBar/`：状态栏图标与颜色动态响应设置切换，过期状态保护
- 实现 `Features/Paywall/PaywallView.swift`：Apple 风格磨砂质感付费墙
- 更新 `Features/Dashboard/`：顶部常驻试用/会员标识，支持快速跳转定制生活目标
- 升级 `Features/Settings/SettingsView.swift`：可视化图标选择网格、配色色盘、目标增删改列表与会员中心
- 扩充单元测试 `SalaryEngineTests.swift`（12 项测试用例全部秒级通过）
- 追加架构决策 `#005`，自动化测试与 `preflight.sh` 检查全绿
- 已成功推送到 GitHub 远程仓库：`https://github.com/chenxia31/Salary.git` (main 分支)

## 三、下一棒从这里开始

**目标**：配置正式 App Store Connect In-App Purchase 商品或增加多设备 iCloud 同步。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- 本地工程：`open SalaryTicker.xcodeproj` 点击 Run
- CLI 运行：`swift run SalaryTicker`

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 已完成 | 3 大新功能已完整闭环并通过自动化测试 |

## 五、待人工决策

- [ ] 在 App Store Connect 中配置 `com.openclaw.salaryticker.unlock` 非消耗型/自动续期项目（生产上线前）

## 六、踩过的坑 / 别再试的路

- 状态栏必须使用 `.monospacedDigit()`，否则每秒数字变化时宽度微颤会影响视觉体验。
- Swift 6 中 `@MainActor` 类的 `deinit` 必须配合 `@ObservationIgnored` 与 `nonisolated(unsafe)` 管理后台 `Task`，否则触发严格并发编译报错。
- Xcode 中如果不显式配置 `SUPPORTED_PLATFORMS = macosx` 与共享 Scheme，Xcode 会误按上一个 iOS 项目的 iOS 模拟器/设备进行编译，导致报 `'Logger' is only available in iOS 14.0` / `'Observable()' is only available in iOS 17.0`。已在 `project.yml` 中锁定 `SUPPORTED_PLATFORMS: macosx` 与 `SalaryTicker.xcscheme`。
- macOS 状态栏 AppKit 默认会将 MenuBar 里的 SwiftUI `Image` 作为 Template 强制黑白渲染，且不会响应 `.foregroundStyle` 颜色；必须通过原生 `NSImage(systemSymbolName:)` 配合 `SymbolConfiguration(paletteColors:)` 并显式声明 `isTemplate = false`，状态栏图标才能呈现彩色；同时 `StatusBarLabelView` 需直接绑定 `SalarySettingsStore` 并在点击后立即保存，以确保在设置面板点选图标与颜色时状态栏能够即时无缝刷新。

## 七、环境与验证

- 自动化检查：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.010s 全绿）
- Xcode 工程：`SalaryTicker.xcodeproj`（编译运行正常，仅目标设备锁定 My Mac）
