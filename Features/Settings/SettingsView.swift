import SwiftUI
import SalaryTickerCore

public struct SettingsView: View {
    @Bindable var settingsStore: SalarySettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var monthlySalaryInput: String = ""
    @State private var workDaysInput: String = ""

    public init(settingsStore: SalarySettingsStore) {
        self.settingsStore = settingsStore
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
                    // 第一组：薪资核心
                    salarySection

                    // 第二组：工时与午休
                    workScheduleSection

                    // 第三组：状态栏展示模式
                    displaySection

                    // 底部操作
                    bottomActions
                }
                .padding(20)
            }
        }
        .frame(width: 440, height: 560)
        .background(.ultraThinMaterial)
        .onAppear {
            monthlySalaryInput = String(format: "%.0f", settingsStore.settings.monthlySalary)
            workDaysInput = String(format: "%.2f", settingsStore.settings.workDaysPerMonth)
        }
    }

    // MARK: - 薪资设置
    private var salarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(String(localized: "薪资设置"), systemImage: "yensign.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

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

    // MARK: - 工时与午休
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

    // MARK: - 状态栏显示模式
    private var displaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(String(localized: "状态栏显示风格"), systemImage: "menubar.rectangle")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 12) {
                Picker(String(localized: "状态栏模式"), selection: $settingsStore.settings.displayMode) {
                    ForEach(StatusDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Text(String(localized: "小数精度"))
                        .font(.callout)
                    Spacer()
                    Picker("", selection: $settingsStore.settings.decimalPrecision) {
                        Text("2 位小数 (¥ 128.45)").tag(2)
                        Text("4 位小数 (¥ 128.4520)").tag(4)
                    }
                    .frame(width: 180)
                }
            }
            .padding(14)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 底部操作
    private var bottomActions: some View {
        HStack {
            Button(String(localized: "恢复默认")) {
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
}
