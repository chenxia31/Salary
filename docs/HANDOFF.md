# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-09 · by antigravity · 对应 Release：`v1.0.1`

---

## 一、现在做到哪了

1. **默认月薪调整为 80k 并就绪发布 v1.0.1**：
   - 将 `SalarySettings.default` 与初始化默认薪资由 25k 调整为 80,000 元（80k）。
   - 单日收入基数提升至 ~3678 元，全天状态栏流速平滑覆盖各项生活小目标。
   - `SettingsView` 中的输入框占位符同步调整为 80000。
   - 版本号升级至 `v1.0.1`（Build 2）。
2. **发布镜像 DMG 编译完成**：
   - 运行 `./scripts/build_dmg.sh` 编译 Universal Release，生成 `dist/SalaryTicker.dmg`（7.1MB，SHA256: `0f86e83642a3585b6429ef8b30aee4d064777e8e65537437aa1a3ec985597121`）。
3. **质量与工程状态**：
   - 12 项 Swift Testing 纯逻辑单元测试全部通过，预检脚本 `./scripts/preflight.sh` 全绿。

## 二、这一棒做了什么

- 在 `SalarySettings.swift` 中将默认月薪调整为 80000.0（80k）。
- 在 `SettingsView.swift` 中同步月薪输入框占位符为 80000 并递增版本至 v1.0.1。
- 在 `App/Info.plist` 中递增 `CFBundleShortVersionString` 为 1.0.1 与 `CFBundleVersion` 为 2。
- 重新构建 Release DMG 镜像 (`dist/SalaryTicker.dmg`)。
- 记录架构决策 #012，跑通 `./scripts/preflight.sh` 门禁。
- 准备通过 `gh release create v1.0.1` 发布正式 Release。

## 三、下一棒从这里开始

**目标**：完成 GitHub Release `v1.0.1` 的发布，并持续关注社区与用户使用反馈。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- DMG 安装镜像：`dist/SalaryTicker.dmg`
- 视觉资产：`Resources/AppLogo.png`、`Resources/AppIcon.icns`、`Resources/Assets.xcassets`

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | 默认 80k 薪资、v1.0.1 版本递增、Release DMG 编译、测试均已完整闭环 |

## 五、待人工决策

- [ ] 正式发布对外分发时，可按需配置 Apple Developer ID 签名与 Notarization 公证。

## 六、踩过的坑 / 别再试的路

- 修改默认配置时需同步检查 `SalarySettings.default`、`init` 默认参数以及 `SettingsView` 中的占位符。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.005s 全绿）
- DMG 镜像：`dist/SalaryTicker.dmg`（打包生成成功，大小 7.1MB）
