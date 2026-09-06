import Foundation

/// 工作状态枚举
public enum WorkStatus: String, Sendable, Equatable {
    /// 尚未开始上班
    case beforeWork = "beforeWork"
    /// 正在上班工作中 (实时入账中)
    case working = "working"
    /// 午休中
    case lunchBreak = "lunchBreak"
    /// 已下班
    case afterWork = "afterWork"
    /// 24/7 全天候流速计薪中
    case continuous = "continuous"

    public var title: String {
        switch self {
        case .beforeWork:
            return String(localized: "等待开工")
        case .working:
            return String(localized: "正在入账")
        case .lunchBreak:
            return String(localized: "午休充电")
        case .afterWork:
            return String(localized: "今日收工")
        case .continuous:
            return String(localized: "全天流速")
        }
    }
}

/// 核心薪资与工时计算引擎 (纯函数，无状态，完全可测)
public enum SalaryEngine: Sendable {

    /// 计算当日全额薪资
    public static func dailySalary(for settings: SalarySettings) -> Double {
        let workDays = max(settings.workDaysPerMonth, 1.0)
        return settings.monthlySalary / workDays
    }

    /// 计算单日有效工作秒数
    public static func effectiveWorkSeconds(for settings: SalarySettings) -> Double {
        let startSeconds = Double(settings.workStartHour * 3600 + settings.workStartMinute * 60)
        let endSeconds = Double(settings.workEndHour * 3600 + settings.workEndMinute * 60)
        let totalSpan = max(0.0, endSeconds - startSeconds)

        if settings.isLunchPaid {
            return max(totalSpan, 60.0)
        } else {
            let lunchStart = Double(settings.lunchStartHour * 3600 + settings.lunchStartMinute * 60)
            let lunchEnd = Double(settings.lunchEndHour * 3600 + settings.lunchEndMinute * 60)
            let lunchSpan = max(0.0, lunchEnd - lunchStart)
            return max(totalSpan - lunchSpan, 60.0)
        }
    }

    /// 计算每秒入账金额 (元/秒)
    public static func ratePerSecond(for settings: SalarySettings, date: Date = Date(), calendar: Calendar = .current) -> Double {
        if settings.isContinuous247Mode {
            // 全天候 24/7 模式：月薪按当月总天数平摊到每秒
            let daysInMonth = Double(calendar.range(of: .day, in: .month, for: date)?.count ?? 30)
            return settings.monthlySalary / (daysInMonth * 86400.0)
        } else {
            let daily = dailySalary(for: settings)
            let seconds = effectiveWorkSeconds(for: settings)
            return daily / seconds
        }
    }

    /// 计算每分钟入账金额
    public static func ratePerMinute(for settings: SalarySettings, date: Date = Date(), calendar: Calendar = .current) -> Double {
        ratePerSecond(for: settings, date: date, calendar: calendar) * 60.0
    }

    /// 计算每小时时薪
    public static func ratePerHour(for settings: SalarySettings, date: Date = Date(), calendar: Calendar = .current) -> Double {
        ratePerSecond(for: settings, date: date, calendar: calendar) * 3600.0
    }

    /// 计算指定时间点在当天的实际累计入账金额
    public static func calculateTodayEarnings(
        at date: Date,
        settings: SalarySettings,
        calendar: Calendar = .current
    ) -> Double {
        let daily = dailySalary(for: settings)

        if settings.isContinuous247Mode {
            let startOfDay = calendar.startOfDay(for: date)
            let elapsedSeconds = date.timeIntervalSince(startOfDay)
            let rate = ratePerSecond(for: settings, date: date, calendar: calendar)
            return min(daily, max(0.0, elapsedSeconds * rate))
        }

        // 构造当天的上下班与午休具体时间
        let startOfDay = calendar.startOfDay(for: date)
        guard let workStart = calendar.date(bySettingHour: settings.workStartHour, minute: settings.workStartMinute, second: 0, of: startOfDay),
              let workEnd = calendar.date(bySettingHour: settings.workEndHour, minute: settings.workEndMinute, second: 0, of: startOfDay),
              let lunchStart = calendar.date(bySettingHour: settings.lunchStartHour, minute: settings.lunchStartMinute, second: 0, of: startOfDay),
              let lunchEnd = calendar.date(bySettingHour: settings.lunchEndHour, minute: settings.lunchEndMinute, second: 0, of: startOfDay) else {
            return 0.0
        }

        if date <= workStart {
            return 0.0
        }
        if date >= workEnd {
            return daily
        }

        let rate = ratePerSecond(for: settings, date: date, calendar: calendar)

        if settings.isLunchPaid {
            let elapsed = date.timeIntervalSince(workStart)
            return min(daily, max(0.0, elapsed * rate))
        }

        // 午休不计薪
        if date < lunchStart {
            let elapsed = date.timeIntervalSince(workStart)
            return min(daily, max(0.0, elapsed * rate))
        } else if date < lunchEnd {
            let morningElapsed = lunchStart.timeIntervalSince(workStart)
            return min(daily, max(0.0, morningElapsed * rate))
        } else {
            let morningElapsed = lunchStart.timeIntervalSince(workStart)
            let afternoonElapsed = date.timeIntervalSince(lunchEnd)
            let totalElapsed = morningElapsed + afternoonElapsed
            return min(daily, max(0.0, totalElapsed * rate))
        }
    }

    /// 判断当前时间点的工作状态
    public static func currentWorkStatus(
        at date: Date,
        settings: SalarySettings,
        calendar: Calendar = .current
    ) -> WorkStatus {
        if settings.isContinuous247Mode {
            return .continuous
        }

        let startOfDay = calendar.startOfDay(for: date)
        guard let workStart = calendar.date(bySettingHour: settings.workStartHour, minute: settings.workStartMinute, second: 0, of: startOfDay),
              let workEnd = calendar.date(bySettingHour: settings.workEndHour, minute: settings.workEndMinute, second: 0, of: startOfDay),
              let lunchStart = calendar.date(bySettingHour: settings.lunchStartHour, minute: settings.lunchStartMinute, second: 0, of: startOfDay),
              let lunchEnd = calendar.date(bySettingHour: settings.lunchEndHour, minute: settings.lunchEndMinute, second: 0, of: startOfDay) else {
            return .beforeWork
        }

        if date < workStart {
            return .beforeWork
        } else if date >= workEnd {
            return .afterWork
        } else if date >= lunchStart && date < lunchEnd {
            return .lunchBreak
        } else {
            return .working
        }
    }

    /// 今日工时进度百分比 (0.0 ~ 1.0)
    public static func workProgress(
        at date: Date,
        settings: SalarySettings,
        calendar: Calendar = .current
    ) -> Double {
        let daily = dailySalary(for: settings)
        guard daily > 0 else { return 0.0 }
        let earned = calculateTodayEarnings(at: date, settings: settings, calendar: calendar)
        return min(1.0, max(0.0, earned / daily))
    }

    /// 距离下班剩余秒数 (若已下班或尚未上班返回相应区间)
    public static func secondsUntilWorkEnd(
        at date: Date,
        settings: SalarySettings,
        calendar: Calendar = .current
    ) -> TimeInterval {
        let startOfDay = calendar.startOfDay(for: date)
        guard let workEnd = calendar.date(bySettingHour: settings.workEndHour, minute: settings.workEndMinute, second: 0, of: startOfDay) else {
            return 0
        }
        return max(0, workEnd.timeIntervalSince(date))
    }

    /// 当月累计预估收入 (结合当月已过去的工作日与今日收入)
    public static func monthAccumulatedEstimate(
        at date: Date,
        settings: SalarySettings,
        calendar: Calendar = .current
    ) -> Double {
        let dayOfMonth = calendar.component(.day, from: date)
        let totalDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 30

        if settings.isContinuous247Mode {
            let dayRatio = Double(dayOfMonth - 1) / Double(totalDays)
            let pastDaysEarnings = settings.monthlySalary * dayRatio
            let todayEarnings = calculateTodayEarnings(at: date, settings: settings, calendar: calendar)
            return min(settings.monthlySalary, pastDaysEarnings + todayEarnings)
        }

        // 计算月初至今已经过去的正常工作日天数 (周一至周五)
        var workDaysElapsed = 0
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components) else { return 0 }

        for dayOffset in 0..<(dayOfMonth - 1) {
            if let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth) {
                let weekday = calendar.component(.weekday, from: targetDate)
                // 1 为周日, 7 为周六
                if weekday != 1 && weekday != 7 {
                    workDaysElapsed += 1
                }
            }
        }

        let daily = dailySalary(for: settings)
        let pastWorkDaysEarnings = Double(workDaysElapsed) * daily
        let todayEarnings = calculateTodayEarnings(at: date, settings: settings, calendar: calendar)
        return min(settings.monthlySalary, pastWorkDaysEarnings + todayEarnings)
    }

    // MARK: - 格式化辅助方法

    /// 格式化金额字符串
    public static func formatCurrency(
        _ amount: Double,
        symbol: String = "¥",
        precision: Int = 2
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = precision
        formatter.maximumFractionDigits = precision
        let formattedNumber = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.\(precision)f", amount)
        return "\(symbol) \(formattedNumber)"
    }

    /// 格式化每秒流速
    public static func formatRatePerSecond(
        _ rate: Double,
        symbol: String = "¥",
        precision: Int = 4
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = precision
        formatter.maximumFractionDigits = precision
        let formattedNumber = formatter.string(from: NSNumber(value: rate)) ?? String(format: "%.\(precision)f", rate)
        return "+\(symbol)\(formattedNumber)/s"
    }

    /// 格式化剩余倒计时 (例如：2小时35分10秒)
    public static func formatRemainingCountdown(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        if totalSeconds <= 0 {
            return String(localized: "已收工")
        }
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60

        if hours > 0 {
            return String(localized: "\(hours)小时\(minutes)分\(secs)秒")
        } else if minutes > 0 {
            return String(localized: "\(minutes)分\(secs)秒")
        } else {
            return String(localized: "\(secs)秒")
        }
    }
}
