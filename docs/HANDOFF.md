# HANDOFF · 接力棒

> **规则**
> 1. **覆盖式重写**，永远只描述"现在" —— 历史在 `git log` 里，这里不堆流水账
> 2. 每个 AI session 结束前必须更新，未更新等于任务未完成
> 3. 控制在 100 行以内。写不下说明你想留的是历史，删掉它
> 4. 写给"完全不知道上文的下一棒"看，不要用只有你懂的指代

**最后更新**：2026-09-06 · by antigravity · 对应 commit：`release(dist): 打包独立 DMG 安装镜像并编写精美 README 说明书`

---

## 一、现在做到哪了

1. **DMG 独立安装包构建完成**：
   - 生成高分辨率 Apple 质感应用图标 `Resources/AppIcon.icns`。
   - 编写原生自动化打包脚本 `scripts/build_dmg.sh`。
   - 编译生成 `dist/SalaryTicker.dmg`（1.6MB，内含 `/Applications` 拖拽软链，UDZO 压缩）。
2. **完整开源规范与说明书**：
   - 撰写具备 Apple 美学排版的 `README.md`，包含功能亮点、架构设计、ASCII 视觉预览与快速上手。
   - 添加标准 MIT `LICENSE` 文件。
3. **功能与质量全部就绪**：
   - 包含每秒薪资流速、8 款图标与 7 种配色切换（全彩呈现）、生活目标定制、30 天试用与 ¥1.99 付费。
   - 12 项 Swift Testing 单元测试全部通过，预检脚本 `./scripts/preflight.sh` 全绿。

## 二、这一棒做了什么

- 编写 `scripts/build_dmg.sh`，实现一键归档、提取 .app、生成 Applications 快捷方式与 hdiutil 制作 DMG
- 生成 1024x1024 macOS 质感 App 图标并转为 `Resources/AppIcon.icns`，更新 `project.yml` 并通过 xcodegen 同步
- 打包生成分发镜像 `dist/SalaryTicker.dmg`（挂载校验 CRC32 与 APFS 结构无误）
- 编写顶级高水准 `README.md` 与 `LICENSE`
- 在 `docs/DECISIONS.md` 追加 `#006` 打包架构决策
- 跑通 `./scripts/preflight.sh` 确保构建与测试 100% 通过

## 三、下一棒从这里开始

**目标**：在 GitHub Releases 中发布 v1.0.0 标签并挂载 DMG，或接入正式 App Store 证书签名。

**入口**：
- 远程仓库：`https://github.com/chenxia31/Salary.git`
- DMG 安装镜像：`dist/SalaryTicker.dmg`
- 一键打包脚本：`./scripts/build_dmg.sh`
- 本地工程：`open SalaryTicker.xcodeproj`
- CLI 测试：`./scripts/preflight.sh`

## 四、当前是"半成品"的地方

| 位置 | 状态 | 说明 |
|---|---|---|
| 无 | 完整交付 | DMG、文档、单元测试、状态栏逻辑均已闭环 |

## 五、待人工决策

- [ ] 正式上线如需分发到外部非开发者机器，可使用 Apple Developer 开发者账号执行 `codesign --sign "Developer ID Application"` 与 `xcrun notarytool` 进行公证。当前 DMG 为开发测试与本地免证书直接安装模式。

## 六、踩过的坑 / 别再试的路

- 制作 DMG 时必须创建指向 `/Applications` 的符号链接（`ln -s /Applications`），便于用户双击后直接拖拽安装。
- macOS AppKit 默认对状态栏图标启用 Template 强制单色渲染，必须通过原生 `NSImage(systemSymbolName:)` 配合 `SymbolConfiguration(paletteColors:)` 并显式声明 `isTemplate = false`。
- xcodebuild 在 CLI 下执行需保证 `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` 指向完整 Xcode 实例。

## 七、环境与验证

- 预检门禁：`./scripts/preflight.sh`（全绿）
- 单元测试：`swift test`（12 项测试 0.008s 全绿）
- DMG 镜像：`dist/SalaryTicker.dmg`（hdiutil 挂载、校验、卸载成功）
