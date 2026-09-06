import SwiftUI
import SalaryTickerCore

public struct SettingsView: View {
    @Bindable var settingsStore: SalarySettingsStore
    @Bindable var subscriptionStore: SubscriptionStore = .shared
    @Environment(\.dismiss) private var dismiss

    @State private var monthlySalaryInput: String = ""
    @State private var workDaysInput: String = ""
    @State private var isShowingPaywall: Bool = false

    // 图标候选库
    private let availableIcons: [(id: String, name: String)] = [
        ("banknote.fill", "纸币"),
        ("dollarsign.circle.fill", "金币"),
        ("chart.line.uptrend.xyaxis", "走势"),
        ("sparkles", "星芒"),
        ("flame.fill", "烈焰"),
        ("cup.and.saucer.fill", "咖啡"),
        ("hourglass", "沙漏"),
        ("laptopcomputer", "搬砖")
    ]

    // 配色方案库
    private let availableColorThemes: [(id: String, name: String, color: Color)] = [
        ("dynamic", "自适应", .green),
        ("emerald", "薄荷绿", .mint),
        ("gold", "流光金", .yellow),
        ("skyBlue", "天空蓝", .cyan),
        ("coral", "日落橙", .orange),
        ("purple", "极光紫", .purple),
        ("monochrome", "单色", .primary)
    ]

    public init(settingsStore: SalarySettingsStore, subscriptionStore: SubscriptionStore = .shared) {
        self.settingsStore = settingsStore
        self.subscriptionStore = subscriptionStore
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Text(String(localized: "偏好设置"))
                    .font(.headline.weight(.semibold))

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 12)

            Divider()

            ScrollView {
                VStack(spacing: 18) {
                    // 1. 会员与试用状态
                    subscriptionSection

                    // 2. 菜单栏外观风格（图标与颜色）
                    appearanceSection

                    // 3. 生活打工小目标定制
                    milestonesSection

                    // 4. 薪资设置
                    salarySection

                    // 5. 工时与作息
                    workScheduleSection

                    // 6. 底部操作
                    bottomActions
                }
                .padding(20)
            }
        }
        .frame(width: 480, height: 640)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView(subscriptionStore: subscriptionStore)
        }
        .onAppear {
            monthlySalaryInput = String(format: "%.0f", settingsStore.settings.monthlySalary)
            workDaysInput = String(format: "%.2f", settingsStore.settings.workDaysPerMonth)
        }
    }

    // MARK: - 会员与试用专区
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(String(localized: "会员与试用"), systemImage: "crown.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.orange)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(subscriptionStore.statusBadgeText)
                        .font(.callout.weight(.bold))
                        .foregroundStyle(subscriptionStore.isProUnlocked ? .green : .orange)
                    Text(String(localized: "30 天全功能免费试用 · ¥1.99 买断永久"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    isShowingPaywall = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text(subscriptionStore.isProUnlocked ? String(localized: "会员中心") : String(localized: "升级解锁"))
                    }
                    .font(.caption.weight(.bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.regular)
            }
            .padding(14)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 菜单栏外观风格 (图标与颜色)
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(String(localized: "状态栏外观风格"), systemImage: "paintpalette.fill")
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 14) {
                // 实时效果预览
                HStack(spacing: 8) {
                    Text(String(localized: "状态栏效果预览:"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 6) {
                        previewIcon(for: settingsStore.settings.statusIcon, theme: settingsStore.settings.statusColorTheme)
                        Text("¥ 128.45")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                    }
                }

                // 显示模式
                Picker(String(localized: "显示模式"), selection: $settingsStore.settings.displayMode) {
                    ForEach(StatusDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: settingsStore.settings.displayMode) { _, _ in
                    settingsStore.save()
                }

                // 菜单栏图标更换
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "状态栏图标 (点击即生效)"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ForEach(availableIcons, id: \.id) { item in
                            let isSelected = settingsStore.settings.statusIcon == item.id
                            Button {
                                settingsStore.settings.statusIcon = item.id
                                settingsStore.save()
                            } label: {
                                VStack(spacing: 4) {
                                    previewIcon(for: item.id, theme: isSelected ? settingsStore.settings.statusColorTheme : "monochrome")
                                        .frame(height: 18)
                                    Text(item.name)
                                        .font(.system(size: 10))
                                        .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(isSelected ? AnyShapeStyle(.quaternary) : AnyShapeStyle(.clear), in: RoundedRectangle(cornerRadius: 8))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(isSelected ? Color.accentColor : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 0.5)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // 菜单栏色彩主题更换
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "色彩主题 (点击即生效)"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ForEach(availableColorThemes, id: \.id) { theme in
                            let isSelected = settingsStore.settings.statusColorTheme == theme.id
                            Button {
                                settingsStore.settings.statusColorTheme = theme.id
                                settingsStore.save()
                            } label: {
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(theme.color)
                                        .frame(width: 8, height: 8)
                                    Text(theme.name)
                                        .font(.caption2.weight(.medium))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(isSelected ? AnyShapeStyle(.quaternary) : AnyShapeStyle(.clear), in: Capsule())
                                .overlay {
                                    Capsule()
                                        .strokeBorder(isSelected ? Color.accentColor : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 0.5)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                HStack {
                    Text(String(localized: "小数精度"))
                        .font(.callout)
                    Spacer()
                    Picker("", selection: $settingsStore.settings.decimalPrecision) {
                        Text("2 位小数 (¥ 128.45)").tag(2)
                        Text("4 位小数 (¥ 128.4520)").tag(4)
                    }
                    .frame(width: 180)
                    .onChange(of: settingsStore.settings.decimalPrecision) { _, _ in
                        settingsStore.save()
                    }
                }
            }
            .padding(14)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 生活打工目标定制
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(String(localized: "生活打工小目标"), systemImage: "target")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Button {
                    let newItem = MilestoneItem(
                        title: String(localized: "新目标"),
                        targetAmount: 50.0,
                        icon: "gift.fill"
                    )
                    settingsStore.settings.milestones.append(newItem)
                    settingsStore.save()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "plus.circle.fill")
                        Text(String(localized: "添加目标"))
                    }
                    .font(.caption2.weight(.medium))
                }
                .buttonStyle(.borderless)

                Button {
                    settingsStore.settings.milestones = SalarySettings.default.milestones
                    settingsStore.save()
                } label: {
                    Text(String(localized: "重置"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
            }

            VStack(spacing: 8) {
                ForEach($settingsStore.settings.milestones) { $item in
                    HStack(spacing: 8) {
                        Image(systemName: item.icon)
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                            .frame(width: 24)

                        TextField(String(localized: "目标名称"), text: $item.title)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)
                            .onChange(of: item.title) { _, _ in
                                settingsStore.save()
                            }

                        Text(settingsStore.settings.currencySymbol)
                            .foregroundStyle(.secondary)

                        TextField("50", value: $item.targetAmount, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: item.targetAmount) { _, _ in
                                settingsStore.save()
                            }

                        if settingsStore.settings.milestones.count > 1 {
                            Button {
                                settingsStore.settings.milestones.removeAll { $0.id == item.id }
                                settingsStore.save()
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(14)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 薪资设置
    private var salarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(String(localized: "薪资设置"), systemImage: "yensign.circle.fill")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 10) {
                HStack {
                    Text(String(localized: "税前/到手月薪"))
                        .font(.callout)
                    Spacer()
                    TextField("25000", text: $monthlySalaryInput)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 140)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: monthlySalaryInput) { _, newValue in
                            if let val = Double(newValue), val > 0 {
                                settingsStore.settings.monthlySalary = val
                            }
                        }
                    Text(settingsStore.settings.currencySymbol)
                        .foregroundStyle(.secondary)
                }

                // 快捷月薪按钮
                HStack(spacing: 6) {
                    ForEach([15000, 25000, 35000, 50000, 80000], id: \.self) { amount in
                        Button("¥\(amount / 1000)k") {
                            settingsStore.settings.monthlySalary = Double(amount)
                            monthlySalaryInput = "\(amount)"
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "每月计薪天数"))
                            .font(.callout)
                        Text(String(localized: "中国法定月平均工作天数为 21.75 天"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    TextField("21.75", text: $workDaysInput)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: workDaysInput) { _, newValue in
                            if let val = Double(newValue), val > 0 {
                                settingsStore.settings.workDaysPerMonth = val
                            }
                        }
                    Text(String(localized: "天"))
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text(String(localized: "货币符号"))
                        .font(.callout)
                    Spacer()
                    Picker("", selection: $settingsStore.settings.currencySymbol) {
                        Text("¥ (人民币)").tag("¥")
                        Text("$ (美元)").tag("$")
                        Text("€ (欧元)").tag("€")
                        Text("£ (英镑)").tag("£")
                        Text("HK$ (港币)").tag("HK$")
                    }
                    .frame(width: 130)
                }
            }
            .padding(14)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 工时与作息
    private var workScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(String(localized: "工时与作息"), systemImage: "clock.badge.checkmark.fill")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 12) {
                // 上下班时间
                HStack {
                    Text(String(localized: "上下班时间"))
                        .font(.callout)
                    Spacer()
                    timePicker(
                        hour: $settingsStore.settings.workStartHour,
                        minute: $settingsStore.settings.workStartMinute
                    )
                    Text("~")
                        .foregroundStyle(.secondary)
                    timePicker(
                        hour: $settingsStore.settings.workEndHour,
                        minute: $settingsStore.settings.workEndMinute
                    )
                }

                Divider()

                // 午休时间
                HStack {
                    Text(String(localized: "午休时间"))
                        .font(.callout)
                    Spacer()
                    timePicker(
                        hour: $settingsStore.settings.lunchStartHour,
                        minute: $settingsStore.settings.lunchStartMinute
                    )
                    Text("~")
                        .foregroundStyle(.secondary)
                    timePicker(
                        hour: $settingsStore.settings.lunchEndHour,
                        minute: $settingsStore.settings.lunchEndMinute
                    )
                }

                Toggle(isOn: $settingsStore.settings.isLunchPaid) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "午休时间照常计薪"))
                            .font(.callout)
                        Text(String(localized: "若开启，午休期间每秒薪资不暂停"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                Toggle(isOn: $settingsStore.settings.isContinuous247Mode) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "24/7 全天候流速计薪模式"))
                            .font(.callout)
                        Text(String(localized: "适合自由职业者/被动收入，全天24小时每秒均匀计薪"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 底部操作
    private var bottomActions: some View {
        HStack {
            Button(String(localized: "恢复全部默认")) {
                settingsStore.resetToDefault()
                monthlySalaryInput = String(format: "%.0f", settingsStore.settings.monthlySalary)
                workDaysInput = String(format: "%.2f", settingsStore.settings.workDaysPerMonth)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)

            Spacer()

            Button(String(localized: "完成")) {
                settingsStore.save()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
        }
        .padding(.top, 6)
    }

    // 时间选择控件
    private func timePicker(hour: Binding<Int>, minute: Binding<Int>) -> some View {
        HStack(spacing: 2) {
            Picker("", selection: hour) {
                ForEach(0..<24) { h in
                    Text(String(format: "%02d", h)).tag(h)
                }
            }
            .frame(width: 54)
            .labelsHidden()

            Text(":")

            Picker("", selection: minute) {
                ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { m in
                    Text(String(format: "%02d", m)).tag(m)
                }
            }
            .frame(width: 54)
            .labelsHidden()
        }
    }

    // 渲染带有颜色和模板设置的图标预览
    private func previewIcon(for iconName: String, theme: String) -> some View {
        let nsColor: NSColor
        switch theme {
        case "emerald":
            nsColor = .systemMint
        case "gold":
            nsColor = .systemYellow
        case "skyBlue":
            nsColor = .systemCyan
        case "coral":
            nsColor = .systemOrange
        case "purple":
            nsColor = .systemPurple
        case "monochrome":
            nsColor = .labelColor
        default:
            nsColor = .systemGreen
        }

        let base = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) ?? NSImage()
        if theme == "monochrome" {
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
            let img = base.withSymbolConfiguration(config) ?? base
            img.isTemplate = true
            return Image(nsImage: img)
        } else {
            let config = NSImage.SymbolConfiguration(paletteColors: [nsColor])
                .applying(.init(pointSize: 13, weight: .semibold))
            if let tinted = base.withSymbolConfiguration(config) {
                tinted.isTemplate = false
                return Image(nsImage: tinted)
            }
            base.isTemplate = false
            return Image(nsImage: base)
        }
    }
}
