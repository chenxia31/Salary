import Foundation
import Observation
import os

/// 状态栏显示模式
public enum StatusDisplayMode: String, Codable, CaseIterable, Sendable {
    /// 今日累计入账 (例如：¥ 142.85)
    case todayEarned = "todayEarned"
    /// 每秒入账流速 (例如：+0.048/s)
    case ratePerSecond = "ratePerSecond"
    /// 紧凑图标与金额 (例如：􀅵 ¥142.85)
    case compact = "compact"
    /// 仅显示图标 (隐私防偷窥模式)
    case iconOnly = "iconOnly"

    public var title: String {
        switch self {
        case .todayEarned:
            return String(localized: "今日入账")
        case .ratePerSecond:
            return String(localized: "每秒流速")
        case .compact:
            return String(localized: "紧凑金额")
        case .iconOnly:
            return String(localized: "仅图标(防窥)")
        }
    }
}

/// 打工人趣味里程碑项
public struct MilestoneItem: Codable, Identifiable, Sendable, Equatable {
    public var id: UUID
    public var title: String
    public var targetAmount: Double
    public var icon: String

    public init(id: UUID = UUID(), title: String, targetAmount: Double, icon: String) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.icon = icon
    }
}

/// 薪资与工时设置数据结构
public struct SalarySettings: Codable, Sendable, Equatable {
    /// 月薪 (元)
    public var monthlySalary: Double
    /// 每月计薪工作天数 (默认中国法定平均 21.75 天)
    public var workDaysPerMonth: Double
    /// 上班时间 (小时, 0~23)
    public var workStartHour: Int
    /// 上班时间 (分钟, 0~59)
    public var workStartMinute: Int
    /// 下班时间 (小时, 0~23)
    public var workEndHour: Int
    /// 下班时间 (分钟, 0~59)
    public var workEndMinute: Int
    /// 午休开始时间 (小时)
    public var lunchStartHour: Int
    /// 午休开始时间 (分钟)
    public var lunchStartMinute: Int
    /// 午休结束时间 (小时)
    public var lunchEndHour: Int
    /// 午休结束时间 (分钟)
    public var lunchEndMinute: Int
    /// 午休是否计薪
    public var isLunchPaid: Bool
    /// 24/7 全天候流速计薪模式 (自由职业者 / 被动收入)
    public var isContinuous247Mode: Bool
    /// 货币符号 (例如 "¥", "$", "€")
    public var currencySymbol: String
    /// 状态栏展示模式
    public var displayMode: StatusDisplayMode
    /// 小数点位数精度 (2 或 4 位)
    public var decimalPrecision: Int
    /// 状态栏图标 (SF Symbol 名称)
    public var statusIcon: String
    /// 状态栏色彩主题
    public var statusColorTheme: String
    /// 自定义里程碑
    public var milestones: [MilestoneItem]
    /// 微信支付收款码内容或赞赏链接
    public var wechatPayQRContent: String
    /// 支付宝收款码内容或支付链接
    public var alipayPayQRContent: String

    public static let `default` = SalarySettings(
        monthlySalary: 25000.0,
        workDaysPerMonth: 21.75,
        workStartHour: 9,
        workStartMinute: 30,
        workEndHour: 18,
        workEndMinute: 30,
        lunchStartHour: 12,
        lunchStartMinute: 0,
        lunchEndHour: 13,
        lunchEndMinute: 30,
        isLunchPaid: false,
        isContinuous247Mode: false,
        currencySymbol: "¥",
        displayMode: .todayEarned,
        decimalPrecision: 2,
        statusIcon: "banknote.fill",
        statusColorTheme: "dynamic",
        milestones: [
            MilestoneItem(title: "提神咖啡", targetAmount: 25.0, icon: "cup.and.saucer.fill"),
            MilestoneItem(title: "午餐外卖", targetAmount: 45.0, icon: "takeoutbag.and.cup.and.straw.fill"),
            MilestoneItem(title: "今日房租", targetAmount: 120.0, icon: "house.fill"),
            MilestoneItem(title: "下班奶茶", targetAmount: 200.0, icon: "mug.fill"),
            MilestoneItem(title: "日赚千元", targetAmount: 1000.0, icon: "sparkles")
        ],
        wechatPayQRContent: "https://github.com/chenxia31/Salary#wechat-pay",
        alipayPayQRContent: "https://qr.alipay.com/fkx13384rierygpezadhk2e"
    )

    public init(
        monthlySalary: Double = 25000.0,
        workDaysPerMonth: Double = 21.75,
        workStartHour: Int = 9,
        workStartMinute: Int = 30,
        workEndHour: Int = 18,
        workEndMinute: Int = 30,
        lunchStartHour: Int = 12,
        lunchStartMinute: Int = 0,
        lunchEndHour: Int = 13,
        lunchEndMinute: Int = 30,
        isLunchPaid: Bool = false,
        isContinuous247Mode: Bool = false,
        currencySymbol: String = "¥",
        displayMode: StatusDisplayMode = .todayEarned,
        decimalPrecision: Int = 2,
        statusIcon: String = "banknote.fill",
        statusColorTheme: String = "dynamic",
        milestones: [MilestoneItem] = SalarySettings.default.milestones,
        wechatPayQRContent: String = "https://github.com/chenxia31/Salary#wechat-pay",
        alipayPayQRContent: String = "https://qr.alipay.com/fkx13384rierygpezadhk2e"
    ) {
        self.monthlySalary = monthlySalary
        self.workDaysPerMonth = workDaysPerMonth
        self.workStartHour = workStartHour
        self.workStartMinute = workStartMinute
        self.workEndHour = workEndHour
        self.workEndMinute = workEndMinute
        self.lunchStartHour = lunchStartHour
        self.lunchStartMinute = lunchStartMinute
        self.lunchEndHour = lunchEndHour
        self.lunchEndMinute = lunchEndMinute
        self.isLunchPaid = isLunchPaid
        self.isContinuous247Mode = isContinuous247Mode
        self.currencySymbol = currencySymbol
        self.displayMode = displayMode
        self.decimalPrecision = decimalPrecision
        self.statusIcon = statusIcon
        self.statusColorTheme = statusColorTheme
        self.milestones = milestones
        self.wechatPayQRContent = wechatPayQRContent
        self.alipayPayQRContent = alipayPayQRContent
    }

    enum CodingKeys: String, CodingKey {
        case monthlySalary, workDaysPerMonth, workStartHour, workStartMinute
        case workEndHour, workEndMinute, lunchStartHour, lunchStartMinute
        case lunchEndHour, lunchEndMinute, isLunchPaid, isContinuous247Mode
        case currencySymbol, displayMode, decimalPrecision, statusIcon, statusColorTheme
        case milestones, wechatPayQRContent, alipayPayQRContent
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.monthlySalary = try container.decodeIfPresent(Double.self, forKey: .monthlySalary) ?? 25000.0
        self.workDaysPerMonth = try container.decodeIfPresent(Double.self, forKey: .workDaysPerMonth) ?? 21.75
        self.workStartHour = try container.decodeIfPresent(Int.self, forKey: .workStartHour) ?? 9
        self.workStartMinute = try container.decodeIfPresent(Int.self, forKey: .workStartMinute) ?? 30
        self.workEndHour = try container.decodeIfPresent(Int.self, forKey: .workEndHour) ?? 18
        self.workEndMinute = try container.decodeIfPresent(Int.self, forKey: .workEndMinute) ?? 30
        self.lunchStartHour = try container.decodeIfPresent(Int.self, forKey: .lunchStartHour) ?? 12
        self.lunchStartMinute = try container.decodeIfPresent(Int.self, forKey: .lunchStartMinute) ?? 0
        self.lunchEndHour = try container.decodeIfPresent(Int.self, forKey: .lunchEndHour) ?? 13
        self.lunchEndMinute = try container.decodeIfPresent(Int.self, forKey: .lunchEndMinute) ?? 30
        self.isLunchPaid = try container.decodeIfPresent(Bool.self, forKey: .isLunchPaid) ?? false
        self.isContinuous247Mode = try container.decodeIfPresent(Bool.self, forKey: .isContinuous247Mode) ?? false
        self.currencySymbol = try container.decodeIfPresent(String.self, forKey: .currencySymbol) ?? "¥"
        self.displayMode = try container.decodeIfPresent(StatusDisplayMode.self, forKey: .displayMode) ?? .todayEarned
        self.decimalPrecision = try container.decodeIfPresent(Int.self, forKey: .decimalPrecision) ?? 2
        self.statusIcon = try container.decodeIfPresent(String.self, forKey: .statusIcon) ?? "banknote.fill"
        self.statusColorTheme = try container.decodeIfPresent(String.self, forKey: .statusColorTheme) ?? "dynamic"
        self.milestones = try container.decodeIfPresent([MilestoneItem].self, forKey: .milestones) ?? SalarySettings.default.milestones
        self.wechatPayQRContent = try container.decodeIfPresent(String.self, forKey: .wechatPayQRContent) ?? "https://github.com/chenxia31/Salary#wechat-pay"
        self.alipayPayQRContent = try container.decodeIfPresent(String.self, forKey: .alipayPayQRContent) ?? "https://qr.alipay.com/fkx13384rierygpezadhk2e"
    }
}

/// 薪资配置存储管理器
@MainActor
@Observable
public final class SalarySettingsStore {
    private let userDefaultsKey = "com.openclaw.salaryticker.settings"
    private let defaults: UserDefaults

    public var settings: SalarySettings {
        didSet {
            save()
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(SalarySettings.self, from: data) {
            self.settings = decoded
            AppLogger.storage.info("已加载本地薪资配置，月薪: \(decoded.monthlySalary, privacy: .public)")
        } else {
            self.settings = .default
            AppLogger.storage.info("未找到历史配置，初始化默认薪资设置")
        }
    }

    public func save() {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: userDefaultsKey)
            AppLogger.storage.debug("薪资配置已保存至 UserDefaults")
        }
    }

    public func resetToDefault() {
        self.settings = .default
    }
}
