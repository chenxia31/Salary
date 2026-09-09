import SwiftUI
import SalaryTickerCore

public struct DashboardView: View {
    @Bindable var viewModel: StatusBarViewModel
    @State private var isShowingSettings: Bool = false
    @State private var isShowingPaywall: Bool = false

    public init(viewModel: StatusBarViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 16) {
            // 顶部栏：品牌与快捷按钮
            headerBar

            // 试用到期警告栏
            if !viewModel.subscriptionStore.isFeatureUnlocked {
                expiredAlertBanner
            }

            // 核心 Hero 卡片：今日大字入账看板
            heroEarningsCard

            // 三联流速卡片：秒薪、分薪、时薪
            StatsBreakdownView(
                settings: viewModel.currentSettings,
                ratePerSecond: viewModel.ratePerSecond,
                ratePerMinute: viewModel.ratePerMinute,
                ratePerHour: viewModel.ratePerHour
            )

            // 工时进度与下班倒计时卡片
            workProgressCard

            // 打工人小成就 / 生活目标
            MilestoneView(
                milestones: viewModel.currentSettings.milestones,
                todayEarnings: viewModel.todayEarnings,
                currencySymbol: viewModel.currentSettings.currencySymbol,
                onEditTap: {
                    isShowingSettings = true
                }
            )

            // 月度宏观进度
            monthProgressCard

            // 底部操作区
            footerActions
        }
        .padding(20)
        .frame(width: 380)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(settingsStore: viewModel.settingsStore)
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView(subscriptionStore: viewModel.subscriptionStore)
        }
    }

    // MARK: - 顶部导航
    private var headerBar: some View {
        HStack {
            HStack(spacing: 7) {
                AppLogoView(size: 22, cornerRadius: 5)
                Text(String(localized: "时薪"))
                    .font(.headline.weight(.bold))
                Text("SalaryTicker")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 会员/试用期标识按钮
            Button {
                isShowingPaywall = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.subscriptionStore.isProUnlocked ? "crown.fill" : "sparkles")
                        .font(.caption2)
                        .foregroundStyle(viewModel.subscriptionStore.isProUnlocked ? .yellow : .orange)
                    Text(viewModel.subscriptionStore.statusBadgeText)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(viewModel.subscriptionStore.isProUnlocked ? Color.primary : Color.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.quaternary.opacity(0.8), in: Capsule())
            }
            .buttonStyle(.plain)
            .help(String(localized: "查看会员特权与订阅状态"))

            // 偏好设置按钮
            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(String(localized: "偏好设置"))
        }
    }

    // MARK: - 试用到期横幅
    private var expiredAlertBanner: some View {
        Button {
            isShowingPaywall = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "heart.circle.fill")
                    .foregroundStyle(.pink)
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "30 天免费试用已结束"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(String(localized: "支持作者请喝杯水，即可永久激活全部功能"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(String(localized: "赞助支持"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.pink, in: Capsule())
            }
            .padding(10)
            .background(.pink.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.pink.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 核心大字动态看板
    private var heroEarningsCard: some View {
        VStack(spacing: 10) {
            // 工作状态胶囊标签
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.statusDotColor)
                    .frame(width: 8, height: 8)
                Text(viewModel.workStatus.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.quaternary, in: Capsule())

            // 巨幅金额动态跳动
            Text(SalaryEngine.formatCurrency(
                viewModel.todayEarnings,
                symbol: viewModel.currentSettings.currencySymbol,
                precision: viewModel.currentSettings.decimalPrecision
            ))
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(
                LinearGradient(
                    colors: [.primary, .primary.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // 今日全天目标
            HStack(spacing: 4) {
                Text(String(localized: "今日全天应得:"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(SalaryEngine.formatCurrency(
                    viewModel.dailySalary,
                    symbol: viewModel.currentSettings.currencySymbol,
                    precision: 2
                ))
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.quaternary.opacity(0.5))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
        }
    }

    // MARK: - 工时进度与下班倒计时卡片
    private var workProgressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "figure.walk.motion")
                        .foregroundStyle(.teal)
                    Text(String(localized: "今日工时进度"))
                        .font(.subheadline.weight(.semibold))
                }

                Spacer()

                Text(String(format: "%.1f%%", viewModel.workProgress * 100.0))
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.teal)
            }

            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                        .frame(height: 7)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.teal, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geo.size.width, geo.size.width * viewModel.workProgress)), height: 7)
                }
            }
            .frame(height: 7)

            // 底部时间分布与下班倒计时
            HStack {
                if viewModel.currentSettings.isContinuous247Mode {
                    Text(String(localized: "24/7 全天候流速进行中"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    let startStr = String(format: "%02d:%02d", viewModel.currentSettings.workStartHour, viewModel.currentSettings.workStartMinute)
                    let endStr = String(format: "%02d:%02d", viewModel.currentSettings.workEndHour, viewModel.currentSettings.workEndMinute)
                    Text("\(startStr) ~ \(endStr)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 3) {
                    Image(systemName: "hourglass")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(viewModel.workStatus == .afterWork
                         ? String(localized: "今日已达成")
                         : String(localized: "距下班 \(SalaryEngine.formatRemainingCountdown(viewModel.secondsUntilWorkEnd))"))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.quaternary.opacity(0.4))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
        }
    }

    // MARK: - 月度进度卡片
    private var monthProgressCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(String(localized: "当月累计预估"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Text(SalaryEngine.formatCurrency(
                    viewModel.monthEarnings,
                    symbol: viewModel.currentSettings.currencySymbol,
                    precision: 0
                ))
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.primary)

                Text("/ \(SalaryEngine.formatCurrency(viewModel.currentSettings.monthlySalary, symbol: viewModel.currentSettings.currencySymbol, precision: 0))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            let monthRatio = min(1.0, max(0.0, viewModel.monthEarnings / max(1.0, viewModel.currentSettings.monthlySalary)))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.blue)
                        .frame(width: geo.size.width * monthRatio, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.quaternary.opacity(0.3))
        }
    }

    // MARK: - 底部快捷操作
    private var footerActions: some View {
        HStack {
            Button {
                isShowingSettings = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                    Text(String(localized: "调整工时与薪资"))
                }
                .font(.caption.weight(.medium))
            }
            .buttonStyle(.borderless)

            Spacer()

            Button(role: .destructive) {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                    Text(String(localized: "退出"))
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(.top, 4)
    }
}
