# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-09 · by antigravity · 对应 commit：`feat(branding): 在应用全场景集成高定 Logo 并确立随喜赞助发布版`

---

## 一、现在做到哪了

1. **确立 Option 4 随喜赞助模式 (Honor System)**：
   - 彻底摆脱传统商业软件的激活码与网络鉴权捆绑，用户扫码赞助后可直接自主点亮 PRO 永久会员。
   - 100% 本地运行、0 数据上报、0 隐私泄露、0 服务器维护成本。
2. **全应用界面统一植入高定品牌 Logo**：
   - 新增 `Features/Common/AppLogoView.swift`，支持全套 Retina 高清裁切与阴影。
   - **状态栏看板头部**：替换原通用符号，呈现 22x22 精致微缩表盘流速 Logo。
   - **赞助与特权弹窗**：顶部核心展示 54x54 品牌 Logo 与暖心微光徽章。
   - **偏好设置与关于**：导航栏带 Logo 标识，底部新增关于卡片展示 v1.0.0 与开源主页。
3. **发布级 DMG 镜像重新打包就绪**：
   - `Resources/AppLogo.png` 已并入 Xcode 应用 Target 资源。
   - 运行 `./scripts/build_dmg.sh` 编译 Release 并组装 `dist/SalaryTicker.dmg`（4.4MB）。
4. **质量与工程状态**：
   - 12 项 Swift Testing 单元测试全部通过，预检脚本 `./scripts/preflight.sh` 全绿。

## 二、这一棒做了什么

- 实现 `Features/Common/AppLogoView.swift` 原生品牌 Logo 组件，具备多重回退加载。
- 在 `DashboardView`、`PaywallView`、`SettingsView` 全场景深度接入品牌 Logo。
- 在 `project.yml` 中补齐 `AppLogo.png` 依赖并重新生成 Xcode 工程。
- 确立并记录 Decision #009（Honor System 随喜赞助机制）。
- 重新构建 Release DMG 镜像 (`dist/SalaryTicker.dmg`)。
- 运行 `./scripts/preflight.sh` 门禁全绿，更新 spec 与接力文档。

## 三、下一棒从这里开始

**目标**：在 GitHub Releases 中创建正式发布标签（如 `v1.0.0`），上传 `dist/SalaryTicker.dmg`。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- DMG 安装镜像：`dist/SalaryTicker.dmg`
- 视觉资产：`Resources/AppLogo.png`、`Resources/AppIcon.icns`

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | UI Logo 贯通、随喜赞助、测试与 Release DMG 均已闭环并达到工业级发布标准 |

## 五、待人工决策

- [ ] 正式发布对外分发时，可按需配置 Apple Developer ID 签名与 Notarization 公证。

## 六、踩过的坑 / 别再试的路

- 沙盒环境下运行 `swift test` 可能会因为无法写入 `/var/folders` 下的 Clang 缓存而报错，需 BypassSandbox 或通过 preflight 自动化执行。
- `project.yml` 变更后运行 `xcodegen generate` 自动同步 Xcode 结构，避免手改 `.pbxproj`。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.007s 全绿）
- DMG 镜像：`dist/SalaryTicker.dmg`（打包生成成功，大小 4.4MB）
