# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-09 · by antigravity · 对应 commit：`fix(branding): 配置完整 Info.plist 与 Assets.xcassets 修复 App 图标缺失`

---

## 一、现在做到哪了

1. **macOS Finder 应用图标与 DMG 卷标图标彻底修复**：
   - 之前由 XcodeGen `GENERATE_INFOPLIST_FILE: YES` 导出的 Info.plist 缺少 `CFBundleIconFile`，导致 Finder 渲染线框网格占位符。
   - 建立标准 `App/Info.plist`，显式配置 `CFBundleIconFile: AppIcon` 与 `CFBundleIconName: AppIcon`。
   - 建立现代 macOS 原生 `Resources/Assets.xcassets/AppIcon.appiconset`（包含全尺寸 16~1024 Retina 图标），经由 `actool` 编译为 `Assets.car`。
   - 在 DMG 镜像中同时配置了 `.VolumeIcon.icns`，挂载磁盘与 App 均拥有完整的 Apple HIG 精密钟表 Logo 图标。
2. **随喜赞助 4 档（含 0 元无须赞助）与全场景 Logo 贯通**：
   - 0 元档免扫码一键免费直接激活；1.99/5.99/9.99 正常呈现微信/支付宝收款码。
   - 状态栏下拉面板、赞助弹窗、偏好设置与关于卡片全部集成 App Logo。
3. **发布镜像 DMG 重新构建完成**：
   - `dist/SalaryTicker.dmg`（7.1MB，内置 Assets.car、AppIcon.icns 与 .VolumeIcon.icns）。
4. **质量与工程状态**：
   - 12 项 Swift Testing 单元测试全部通过，预检脚本 `./scripts/preflight.sh` 全绿。

## 二、这一棒做了什么

- 定位 Finder 图标缺失的根本原因（自动生成 plist 缺少 CFBundleIconFile 键，且缺乏 Assets.car）。
- 创建标准 `App/Info.plist`，添加 `CFBundleIconFile`、`CFBundleIconName`、`LSUIElement`、`NSHighResolutionCapable` 等配置。
- 使用 `sips` 为 `Resources/Assets.xcassets/AppIcon.appiconset` 生成全套 10 档分辨率高清图标与 `Contents.json`。
- 修改 `project.yml`，设置 `INFOPLIST_FILE: App/Info.plist`、`GENERATE_INFOPLIST_FILE: NO`、`ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon`。
- 增强 `scripts/build_dmg.sh`，添加 DMG 卷标图标与文件属性刷新。
- 重新编译 Release 并打包生成最新 `dist/SalaryTicker.dmg`。
- 记录架构决策 #011，跑通 `./scripts/preflight.sh` 门禁并更新接力文档。

## 三、下一棒从这里开始

**目标**：在 GitHub Releases 中创建正式发布标签（如 `v1.0.0`），上传 `dist/SalaryTicker.dmg`。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- DMG 安装镜像：`dist/SalaryTicker.dmg`
- 视觉资产：`Resources/AppLogo.png`、`Resources/AppIcon.icns`、`Resources/Assets.xcassets`

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | Finder App 图标、DMG 卷标、0 元档、随喜赞助、测试与构建均已彻底闭环 |

## 五、待人工决策

- [ ] 正式发布对外分发时，可按需配置 Apple Developer ID 签名与 Notarization 公证。

## 六、踩过的坑 / 别再试的路

- 切勿仅依赖 Xcode 的 `GENERATE_INFOPLIST_FILE: YES` 来自动推断 macOS 图标。macOS Finder 强制依赖 plist 里的 `CFBundleIconFile` / `CFBundleIconName` 键或 `Assets.car`。必须提供显式 `Info.plist` 与 `Assets.xcassets`。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.005s 全绿）
- DMG 镜像：`dist/SalaryTicker.dmg`（打包生成成功，大小 7.1MB）
