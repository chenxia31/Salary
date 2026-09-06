import SwiftUI
import Observation
import Combine
import SalaryTickerCore

@MainActor
@Observable
public final class StatusBarViewModel {
    public let settingsStore: SalarySettingsStore
    public let subscriptionStore: SubscriptionStore
    public var currentDate: Date = Date()
    @ObservationIgnored
    private nonisolated(unsafe) var timerTask: Task<Void, Never>?

    public init(settingsStore: SalarySettingsStore, subscriptionStore: SubscriptionStore = .shared) {
        self.settingsStore = settingsStore
        self.subscriptionStore = subscriptionStore
        startTicker()
    }

    deinit {
        timerTask?.cancel()
    }

    public func startTicker() {
        timerTask?.cancel()
        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                self?.currentDate = Date()
                // 每秒刷新一次，保证状态栏省电且平滑无抖动
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    public var currentSettings: SalarySettings {
        settingsStore.settings
    }

    public var todayEarnings: Double {
        SalaryEngine.calculateTodayEarnings(at: currentDate, settings: currentSettings)
    }

    public var ratePerSecond: Double {
        SalaryEngine.ratePerSecond(for: currentSettings, date: currentDate)
    }

    public var ratePerHour: Double {
        SalaryEngine.ratePerHour(for: currentSettings, date: currentDate)
    }

    public var ratePerMinute: Double {
        SalaryEngine.ratePerMinute(for: currentSettings, date: currentDate)
    }

    public var workStatus: WorkStatus {
        SalaryEngine.currentWorkStatus(at: currentDate, settings: currentSettings)
    }

    public var workProgress: Double {
        SalaryEngine.workProgress(at: currentDate, settings: currentSettings)
    }

    public var dailySalary: Double {
        SalaryEngine.dailySalary(for: currentSettings)
    }

    public var secondsUntilWorkEnd: TimeInterval {
        SalaryEngine.secondsUntilWorkEnd(at: currentDate, settings: currentSettings)
    }

    public var monthEarnings: Double {
        SalaryEngine.monthAccumulatedEstimate(at: currentDate, settings: currentSettings)
    }

    /// 状态栏呈现文本
    public var statusText: String {
        if !subscriptionStore.isFeatureUnlocked {
            return String(localized: "试用已到期")
        }

        switch currentSettings.displayMode {
        case .todayEarned:
            return SalaryEngine.formatCurrency(
                todayEarnings,
                symbol: currentSettings.currencySymbol,
                precision: currentSettings.decimalPrecision
            )
        case .ratePerSecond:
            return SalaryEngine.formatRatePerSecond(
                ratePerSecond,
                symbol: currentSettings.currencySymbol,
                precision: currentSettings.decimalPrecision == 2 ? 3 : currentSettings.decimalPrecision
            )
        case .compact:
            return SalaryEngine.formatCurrency(
                todayEarnings,
                symbol: currentSettings.currencySymbol,
                precision: 0
            )
        case .iconOnly:
            return ""
        }
    }

    /// 状态圆点工作状态基色
    public var statusDotColor: Color {
        switch workStatus {
        case .working, .continuous:
            return .green
        case .lunchBreak:
            return .orange
        case .beforeWork:
            return .blue
        case .afterWork:
            return .secondary
        }
    }

    /// 用户自选的主题色彩
    public var resolvedColor: Color {
        switch currentSettings.statusColorTheme {
        case "emerald":
            return .mint
        case "gold":
            return .yellow
        case "skyBlue":
            return .cyan
        case "coral":
            return .orange
        case "purple":
            return .purple
        case "monochrome":
            return .primary
        default: // "dynamic"
            return statusDotColor
        }
    }
}
