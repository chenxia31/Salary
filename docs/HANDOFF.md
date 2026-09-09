# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-09 · by antigravity · 对应 Release：`v1.0.0`

---

## 一、现在做到哪了

1. **GitHub Releases v1.0.0 正式发布成功**：
   - 发布地址：`https://github.com/chenxia31/Salary/releases/tag/v1.0.0`
   - Release 构件：`SalaryTicker.dmg`（7.1MB，SHA256: `7c283310b5db2f870d2a56a372b2e783faedfba83ffd57506d197404161c5a68`）。
   - 包含详细的 Markdown Release Notes、功能亮点与安装指引。
2. **App 图标与视觉全场景完整生效**：
   - 显式 `App/Info.plist`（`CFBundleIconFile` / `CFBundleIconName`）与 `Assets.car` + `AppIcon.icns` 双轨。
   - macOS Finder 与 DMG 挂载磁盘卷标均完美显示 Apple HIG 精密机械表盘 Logo。
3. **四档随喜赞助与 0 元免赞助激活**：
   - 包含：🎁 ¥0 无须赞助、💧 ¥1.99 喝杯水、🍗 ¥5.99 加鸡腿、☕ ¥9.99 瑞幸咖啡。
   - 0 元档免扫码一键免费直接激活；其余档位展示微信/支付宝收款码。
4. **质量与工程状态**：
   - 12 项 Swift Testing 纯逻辑单元测试全绿（0.005s），`./scripts/preflight.sh` 全绿。

## 二、这一棒做了什么

- 使用 GitHub CLI (`gh release create`) 创建正式发布 `v1.0.0`，上传安装镜像 `SalaryTicker.dmg`。
- 更新 `README.md` 首页下载徽章与 Releases 直链。
- 跑通 `./scripts/preflight.sh` 门禁，验证所有测试。
- 覆盖式更新 `docs/HANDOFF.md`。

## 三、下一棒从这里开始

**目标**：监控发布反馈、社区推广（V2EX / 即刻 / Twitter）或按需迭代后续小版本（如 `v1.0.1`）。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- Releases 页面：`https://github.com/chenxia31/Salary/releases`
- DMG 下载直链：`https://github.com/chenxia31/Salary/releases/latest/download/SalaryTicker.dmg`

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | v1.0.0 正式版发布、DMG 上传、Finder 图标、0 元档与随喜赞助全部闭环 |

## 五、待人工决策

- [ ] 可视社区分发反馈，考虑申请 Apple Developer ID 证书进行证书签名与苹果官方公证（Notarization）。

## 六、踩过的坑 / 别再试的路

- GitHub Release 直链建议使用 `releases/latest/download/SalaryTicker.dmg`，始终指向最新发布的安装包。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.005s 全绿）
- Releases：`https://github.com/chenxia31/Salary/releases/tag/v1.0.0`（已发布）
