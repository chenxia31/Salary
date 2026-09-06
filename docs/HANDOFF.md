# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-06 · by antigravity · 对应 commit：`feat(sponsor): 将付费改为三档爱心赞助模式（喝杯水/加鸡腿/瑞幸咖啡）`

---

## 一、现在做到哪了

1. **三档随喜爱心赞助全面落地**：
   - 将生硬的商业买断调整为打工人暖心赞助模式：
     - 💧 **¥1.99 · 喝杯水**（解渴润喉）
     - 🍗 **¥5.99 · 加鸡腿**（元气满满）
     - ☕ **¥9.99 · 瑞幸咖啡**（灵感飞扬）
   - 用户选择任意档位均展示专属支付宝收款码与微信二维码，扫码后点击一键激活 PRO 永久特权。
   - `SettingsView` 与 `DashboardView` 提示文案同步更新为「赞助支持 / 赞助中心」。
2. **DMG 镜像与文档全量同步**：
   - 重新打包生成 `dist/SalaryTicker.dmg`（1.8MB），内置全新赞助模块。
   - 追加架构决策 `#008` 到 `docs/DECISIONS.md`，更新 `README.md` 与 `specs/salary-status-bar.md`。
3. **自动化测试与质量门禁**：
   - 12 项 Swift Testing 单元测试全部通过，预检脚本 `./scripts/preflight.sh` 全绿。

## 二、这一棒做了什么

- 实现 `SponsorTier` 数据结构并在 `PaywallView.swift` 呈现三档赞助卡片
- 联动支付宝专属收款码（`Resources/alipay_qr.jpg`）与微信双通道扫码
- 更新 `SettingsView` 与 `DashboardView` 按钮与横幅文案
- 更新 `README.md`、`specs/salary-status-bar.md` 并追加架构决策 `#008`
- 重新运行 `./scripts/build_dmg.sh` 更新 `dist/SalaryTicker.dmg`
- 跑通 `./scripts/preflight.sh` 并保持测试 100% 通过

## 三、下一棒从这里开始

**目标**：在 GitHub Releases 中发布 v1.0.0 标签并挂载 DMG，或在推特/V2EX 发布推广。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- DMG 安装镜像：`dist/SalaryTicker.dmg`
- 赞助测试：点击状态栏 -> 展开面板 -> 赞助支持 -> 体验三档选择与一键激活

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | 三档赞助切换、专属收款码展示、扫码激活均已闭环 |

## 五、待人工决策

- [ ] 后续若需要换用微信个人赞赏码图片，可同样放置于 `Resources/wechat_qr.jpg` 并替换默认资源。

## 六、踩过的坑 / 别再试的路

- `SubscriptionStore.statusBadgeText` 需保持对已解锁状态输出 `PRO 会员`，保证单元测试断言与现有状态机契约不受影响。
- 赞助模式下任意金额档位均可激活完整功能，尊重用户自愿支持原则。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.005s 全绿）
- DMG 镜像：`dist/SalaryTicker.dmg`（打包生成成功，大小 1.8MB）
