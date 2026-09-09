# SPEC · 状态栏实时薪资与今日入账看板 (SalaryTicker)

> 用法：改动预计超过 50 行、或涉及多个文件时，**先写 spec 再写代码**。
> spec 是给 AI 收敛范围用的，不是给人看的文档 —— 简短、可判定、能验收。

**状态**：已确认
**负责这一轮的**：antigravity
**日期**：2026-09-06

## 1. 要解决什么

让用户输入月薪后，在 macOS 顶部状态栏能够实时、华丽且优雅地感知每一秒的入账流速与今日累计所得，并在下拉面板中体验到 Apple 风格的极高美学享受与下班成就感。

## 2. 范围

**做**：
- 支持配置月薪（默认货币符号 ¥，支持切换 $、€、£ 等）。
- 支持配置每月计薪天数（默认中国法定平均 21.75 天，支持快捷选择 20/21/22/自定义）。
- 支持配置上下班时间（如 09:30 ~ 18:30）及午休时间（如 12:00 ~ 13:30，可配置午休是否计薪）。
- 支持 24/7 全天候流速计薪模式与标准工作日模式切换。
- 状态栏实时显示：
  - 动态等宽数字（`.monospacedDigit()`），每秒平滑跳动，杜绝界面晃动。
  - 4 种显示模式：今日已赚、每秒流速、紧凑金额、极简隐私图标。
  - 支持更换菜单栏图标（纸币、金币、飞升走势、星芒、烈焰、咖啡、沙漏、电脑等）。
  - 支持更换状态栏色彩主题（自适应工作状态色、流光金、天空蓝、薄荷绿、暖橙、极光紫、原生单色）。
- 下拉弹窗卡片（Apple HIG 奢华毛玻璃质感）：
  - Hero 巨幅跳动今日已赚金额（精确至小数点后 2~4 位平滑流速）。
  - 时薪、分薪、秒薪三联流速卡片。
  - 今日工时进度条、完成百分比与下班倒计时。
  - 打工人趣味里程碑勋章（支持完全自定义目标名称、金额与图标）。
  - 月度累计收入与月度进度条。
  - 快捷设置与一键修改薪资弹窗。
- 随喜赞助与诚信激活机制（Honor System）：
  - 首次安装激活 30 天免费完整试用期。
  - 支持四档暖心爱心赞助选择：
    - 🎁 ¥0 · 无须赞助（打工不易，体谅打工人，直接一键免费激活）
    - 💧 ¥1.99 · 喝杯水（解渴润喉）
    - 🍗 ¥5.99 · 加鸡腿（元气满满）
    - ☕ ¥9.99 · 瑞幸咖啡（灵感飞扬）
  - 针对付费档位默认展示用户专属支付宝收款码（含头像），支持微信/支付宝双通道扫码切换。
  - 用户扫码后点击「我已完成赞助，点击激活全部特权」或 0 元直接激活立即获得永久 PRO 授权（100% 本地离线隐私，零服务器成本）。
- 品牌视觉与 Logo 全场景贯通：
  - 精密机械钟表与金融荧光流速脉冲高定 Logo（`AppLogoView`）。
  - 下拉看板顶部、随喜赞助弹窗、偏好设置导航栏与关于卡片统一展现品牌 Logo 与版本标识。
- 纯逻辑计算引擎 `SalaryEngine` 与试用管理器独立且具备单元测试覆盖。

**明确不做**：
- 不做云端同步或需要登录的远程账户体系（纯本地存储，保护用户薪资隐私）。
- 不引入外部庞大重量级 UI 依赖或网络爬虫依赖。

## 3. 验收标准

- [ ] 用户在偏好设置中选择不同图标（如金币、走势图）和颜色（如流光金、极光紫），状态栏图标与颜色实时无缝变更。
- [ ] 用户可以新增或修改生活目标（例如将目标改为「一杯咖啡 32元」或「猫粮 80元」），看板即时更新并在今日赚够对应金额后点亮。
- [ ] 首次启动自动显示 30 天免费试用倒计时；付费面板展示微信/支付宝支付二维码与金额。
- [ ] 用户扫码支付后点击激活按钮，应用无缝解锁为 PRO 永久特权。
- [ ] 运行自动化测试通过，预检脚本 `./scripts/preflight.sh` 全绿。
- [ ] 运行自动化测试通过，预检脚本 `./scripts/preflight.sh` 全绿。
- [ ] 用户输入月薪 30000，计薪天数 21.75，工作时间 09:00~18:00（午休 1.5h 不计薪，工作 7.5h=27000s）：
  - 日薪为 ¥1379.31。
  - 每秒入账约为 ¥0.051085/s，每小时时薪约为 ¥183.91/h。
- [ ] 09:00 前显示今日已入账 ¥0.00；18:00 后显示今日已满额入账 ¥1379.31。
- [ ] 上班时间段内，状态栏数字每秒更新，界面无卡顿、数字不抖动。
- [ ] 用户修改月薪或工时后，实时重算并在状态栏立即生效。
- [ ] 运行自动化测试通过，预检脚本 `./scripts/preflight.sh` 全绿。

## 4. 涉及的文件

| 文件 | 动作 | 说明 |
|---|---|---|
| `Core/Calculation/SalaryEngine.swift` | 新增 | 纯数学薪资计算与时间状态引擎 |
| `Core/Storage/SalarySettings.swift` | 新增 | 配置模型与 UserDefaults 持久化 |
| `Core/Logging/AppLogger.swift` | 新增 | 统一 Logger 封装 |
| `Features/StatusBar/StatusBarLabelView.swift` | 新增 | 状态栏图标与金额渲染视图 |
| `Features/StatusBar/StatusBarController.swift` | 新增 | 状态栏定时器驱动与状态管理 |
| `Features/Dashboard/DashboardView.swift` | 新增 | Apple 风格弹窗面板 |
| `Features/Dashboard/MilestoneView.swift` | 新增 | 成就里程碑组件 |
| `Features/Common/AppLogoView.swift` | 新增 | 品牌 Logo 组件与资源加载回退 |
| `Features/Settings/SettingsView.swift` | 新增 | 薪资与工时设置表单 |
| `App/SalaryTickerApp.swift` | 新增 | macOS 应用入口与 MenuBarExtra |
| `Tests/SalaryEngineTests.swift` | 新增 | 纯逻辑 Swift Testing 单元测试 |
| `scripts/preflight.sh` | 新增 | 自动化质量门禁脚本 |

## 5. 数据与状态

- `SalarySettings`：
  - `monthlySalary: Double` (默认 80000.0 / 80k)
  - `workDaysPerMonth: Double` (默认 21.75)
  - `workStartTime: DateComponents` (小时、分钟)
  - `workEndTime: DateComponents`
  - `lunchStartTime: DateComponents`
  - `lunchEndTime: DateComponents`
  - `isLunchPaid: Bool`
  - `isContinuousMode: Bool` (24/7)
  - `displayMode: StatusDisplayMode` (.todayEarned, .ratePerSecond, .compact, .iconOnly)
  - `currencySymbol: String` (默认 "¥")
  - `precision: Int` (2 或 4 位小数)

## 6. 风险与开关

- 风险：状态栏频繁高频刷新可能导致 CPU 占用或文字抖动。
- 规避策略：使用 1 秒刷新率或仅在面板打开时使用 10Hz 微刷，使用 `.monospacedDigit()`，纯 SwiftUI 数据驱动，CPU 占用低于 0.1%。

## 7. 测试

- 单测覆盖：`SalaryEngine` 在上班前、上班中、午休、下班后、跨日、法定天数等边界值测试。
- 手工验证：启动 App，验证状态栏实时跳动、下拉卡片视觉与设置生效。
