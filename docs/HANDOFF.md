# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-06 · by antigravity · 对应 commit：`release(paywall): 移除测试工具箱并接入专属微信支付收款码`

---

## 一、现在做到哪了

1. **发布态纯净界面**：
   - 从 `PaywallView.swift` 彻底移除「🛠 体验与测试工具箱」，界面保持 Apple 原生高质感。
2. **专属收款码双通道闭环**：
   - 支付宝：`Resources/alipay_qr.jpg`（用户专属收款码原图，含中心头像）。
   - 微信支付：从 Downloads 目录提取并接入 `Resources/wechat_qr.jpg`（用户专属收款码，协议 `wxp://f2f0aDonje4-KgQivJ390wPoRky09pcHLId4m4XLNpgYq_k`）。
   - 在 Paywall 面板中切换「🔵 支付宝扫码」与「🟢 微信支付」时，均展示用户本人的高清收款码原图。
3. **分发构件全量就绪**：
   - 重新打包生成纯净发布版 `dist/SalaryTicker.dmg`（1.8MB）。
   - 12 项 Swift Testing 单元测试全部通过，预检脚本 `./scripts/preflight.sh` 全绿。

## 二、这一棒做了什么

- 从 `Downloads/wxzf.jpg` 提取用户真实微信收款码并保存为 `Resources/wechat_qr.jpg`
- 更新 `project.yml` 引入 `wechat_qr.jpg` 资源并通过 xcodegen 同步工程
- 更新 `SalarySettings.swift` 与 `PaywallView.swift` 微信支付配置与图片渲染
- 彻底移除 `PaywallView.swift` 中的「体验与测试工具箱」
- 重新运行 `./scripts/build_dmg.sh` 编译打包 `dist/SalaryTicker.dmg`
- 预检通过，更新交接文档

## 三、下一棒从这里开始

**目标**：在 GitHub Releases 中发布正式 release，或将 DMG 上传分发。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- DMG 安装镜像：`dist/SalaryTicker.dmg`
- 赞助测试：打开 App -> 点击面板爱心赞助 -> 检查支付宝与微信收款码图片

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | 支付宝与微信专属收款码展示、三档爱心赞助、一键激活闭环已就绪 |

## 五、待人工决策

- [ ] 正式发布对外分发时，可按需对 DMG 进行 Developer ID 签名与 Notarization 公证。

## 六、踩过的坑 / 别再试的路

- 微信与支付宝收款码均有独特的二维码样式与中间标识，使用原图渲染能给扫码用户最高的信任感与原生视觉体验。
- 每次新增 Resource 图片资源后，必须运行 `xcodegen generate`，否则 Xcode 打包的 app bundle 内无法检索到新加入的资源文件。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.006s 全绿）
- DMG 镜像：`dist/SalaryTicker.dmg`（打包生成成功，大小 1.8MB）
