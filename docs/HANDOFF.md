# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-09 · by antigravity · 对应 commit：`feat(sponsor): 新增「¥0 无须赞助」档位支持一键免费直接激活 PRO`

---

## 一、现在做到哪了

1. **四档赞助体系与「¥0 无须赞助」零门槛激活全面落地**：
   - 包含：🎁 ¥0 无须赞助、💧 ¥1.99 喝杯水、🍗 ¥5.99 加鸡腿、☕ ¥9.99 瑞幸咖啡。
   - 选中「¥0 无须赞助」时，弹窗自动切换为温情关怀卡片（"打工人不为难打工人"），提供一键免扫码直接激活按钮。
   - 选中其余赞助档位时，正常显示支付宝/微信收款二维码与金额意向。
2. **全界面品牌 Logo 深度贯通**：
   - `AppLogoView` 全面接入状态栏主看板头部、随喜赞助中心、偏好设置导航栏与关于卡片。
3. **发布镜像 DMG 编译完成**：
   - 重新运行 `./scripts/build_dmg.sh` 编译 Universal Release 并打包至 `dist/SalaryTicker.dmg`（4.4MB）。
4. **质量与工程状态**：
   - 12 项 Swift Testing 单元测试全部通过，预检脚本 `./scripts/preflight.sh` 全绿。

## 二、这一棒做了什么

- 在 `PaywallView.swift` 中新增「¥0 无须赞助（打工不易）」档位。
- 拆分 0 元专属免费激活视图与付费扫码卡片逻辑，自适应 4 档卡片布局（宽度调整至 410pt）。
- 更新 `SettingsView.swift` 中的会员副标题与关于栏文案，突出随喜赞助与免费激活双轨模式。
- 确立并记录 Decision #010（新增 ¥0 无须赞助零门槛档位）。
- 重新编译 Release 并打包生成最新 `dist/SalaryTicker.dmg`。
- 跑通 `./scripts/preflight.sh` 门禁，更新 spec 与接力文档。

## 三、下一棒从这里开始

**目标**：在 GitHub Releases 中创建发布标签（如 `v1.0.0`），上传 `dist/SalaryTicker.dmg`。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- DMG 安装镜像：`dist/SalaryTicker.dmg`
- 视觉资产：`Resources/AppLogo.png`、`Resources/AppIcon.icns`

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | 0 元无须赞助、随喜扫码、品牌 Logo、Release DMG 均已闭环并达到工业级发布标准 |

## 五、待人工决策

- [ ] 正式发布对外分发时，可按需配置 Apple Developer ID 签名与 Notarization 公证。

## 六、踩过的坑 / 别再试的路

- 4 档卡片在 390 宽度下略微紧凑，调整弹窗宽度至 410pt 并精简字号后视觉极度舒适。
- 0 元档位无需展示收款二维码，避免增加用户心理压力，直接提供一键激活。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.006s 全绿）
- DMG 镜像：`dist/SalaryTicker.dmg`（打包生成成功，大小 4.4MB）
