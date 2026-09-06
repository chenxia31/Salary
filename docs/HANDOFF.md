# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-06 · by antigravity · 对应 commit：`feat(paywall): 接入用户专属支付宝二维码支付与微信双通道扫码激活`

---

## 一、现在做到哪了

1. **二维码支付全量上线**：
   - 解析用户专属支付宝收款码图片并提取链接 `https://qr.alipay.com/fkx13384rierygpezadhk2e`。
   - 提取保存为 `Resources/alipay_qr.jpg`，打包进应用 Bundle。
   - 实现 `Features/Paywall/QRCodeGenerator.swift` 原生 CoreImage 高清二维码生成。
   - 重构 `Features/Paywall/PaywallView.swift`：默认选中支付宝支付展示用户专属收款码（含头像），支持微信/支付宝一键切换、扫码后点击一键激活 PRO。
2. **DMG 镜像与文档同步更新**：
   - 重新打包生成 `dist/SalaryTicker.dmg`（1.8MB），内置最新二维码支付模块。
   - 更新 `README.md` 与 `specs/salary-status-bar.md`。
   - 追加架构决策 `#007` 到 `docs/DECISIONS.md`。
3. **自动化测试与质量门禁**：
   - 12 项 Swift Testing 测试全绿，`./scripts/preflight.sh` 全部通过。

## 二、这一棒做了什么

- 将用户上传的支付宝收款码图片保存为 `Resources/alipay_qr.jpg`，并在 `project.yml` 中配置资源
- 扩展 `SalarySettings.swift` 增加 `alipayPayQRContent` 与 `wechatPayQRContent`
- 编写 `QRCodeGenerator.swift` 实现原生 CIFilter 二维码渲染引擎
- 重构 `PaywallView.swift` 为双通道扫码支付卡片与即时激活反馈
- 运行 `./scripts/build_dmg.sh` 更新 `dist/SalaryTicker.dmg`
- 预检通过，更新规格书、决策记录与交接文档

## 三、下一棒从这里开始

**目标**：在 GitHub Releases 中发布 v1.0.0 标签并挂载 DMG，或在推特/V2EX 发布推广。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- DMG 安装镜像：`dist/SalaryTicker.dmg`
- 付费测试：点击状态栏 -> 底部升级解锁 -> 扫描支付宝二维码测试激活

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | 支付宝收款码展示、扫码激活、状态持久化均已打通 |

## 五、待人工决策

- [ ] 后续若需要换用微信个人赞赏码图片，可同样放置于 `Resources/wechat_qr.jpg` 并替换默认资源。

## 六、踩过的坑 / 别再试的路

- 支付宝收款码含有中间自定义头像，直接用纯 CoreImage 绘制会丢失头像，因此需优先读取并展示 `Resources/alipay_qr.jpg` 原始图片，同时兼容解码出的 URL 动态重绘。
- 修改资源文件后需重新运行 `xcodegen generate` 更新工程结构后再执行 Release 编译。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.008s 全绿）
- DMG 镜像：`dist/SalaryTicker.dmg`（编译与挂载校验成功）
