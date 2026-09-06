import Foundation
import Observation
import StoreKit
import os

/// 订阅与 30 天试用管理器
@MainActor
@Observable
public final class SubscriptionStore {
    private let firstLaunchKey = "com.openclaw.salaryticker.first_launch"
    private let proUnlockedKey = "com.openclaw.salaryticker.is_pro"
    private let mockExpiredKey = "com.openclaw.salaryticker.mock_expired"

    public static let shared = SubscriptionStore()
    public nonisolated static let productId = "com.openclaw.salaryticker.unlock"

    /// 试用总天数
    public let totalTrialDays: Int = 30

    /// 是否已永久付费解锁
    public var isProUnlocked: Bool {
        didSet {
            UserDefaults.standard.set(isProUnlocked, forKey: proUnlockedKey)
        }
    }

    /// 模拟测试：强制试用期过期
    public var mockTrialExpired: Bool {
        didSet {
            UserDefaults.standard.set(mockTrialExpired, forKey: mockExpiredKey)
        }
    }

    /// 首次启动时间
    public private(set) var firstLaunchDate: Date

    public init(defaults: UserDefaults = .standard) {
        if let storedDate = defaults.object(forKey: firstLaunchKey) as? Date {
            self.firstLaunchDate = storedDate
        } else {
            let now = Date()
            defaults.set(now, forKey: firstLaunchKey)
            self.firstLaunchDate = now
        }

        self.isProUnlocked = defaults.bool(forKey: proUnlockedKey)
        self.mockTrialExpired = defaults.bool(forKey: mockExpiredKey)

        // 监听 StoreKit 交易更新
        listenForTransactions()
    }

    /// 试用期剩余天数
    public var daysRemaining: Int {
        if mockTrialExpired {
            return 0
        }
        let calendar = Calendar.current
        guard let expireDate = calendar.date(byAdding: .day, value: totalTrialDays, to: firstLaunchDate) else {
            return 0
        }
        let components = calendar.dateComponents([.day], from: Date(), to: expireDate)
        return max(0, components.day ?? 0)
    }

    /// 试用期是否仍在生效
    public var isTrialActive: Bool {
        if mockTrialExpired {
            return false
        }
        return daysRemaining > 0
    }

    /// 当前核心功能是否已解锁 (在试用期内 或 已付费)
    public var isFeatureUnlocked: Bool {
        isProUnlocked || isTrialActive
    }

    /// 会员状态标签文本
    public var statusBadgeText: String {
        if isProUnlocked {
            return String(localized: "PRO 会员")
        } else if isTrialActive {
            return String(localized: "免费试用还剩 \(daysRemaining) 天")
        } else {
            return String(localized: "试用已到期")
        }
    }

    // MARK: - 购买与恢复操作

    /// 模拟或快捷直接解锁 (便于开发测试及用户免沙盒验证)
    public func unlockProDirectly() {
        self.isProUnlocked = true
        self.mockTrialExpired = false
        AppLogger.storage.info("PRO 会员已成功激活")
    }

    /// 恢复购买
    public func restorePurchases() async {
        try? await AppStore.sync()
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productId {
                self.isProUnlocked = true
                await transaction.finish()
                AppLogger.storage.info("已通过 StoreKit 恢复购买")
                return
            }
        }
    }

    /// 重置试用状态 (供测试使用)
    public func resetTrial() {
        self.firstLaunchDate = Date()
        UserDefaults.standard.set(self.firstLaunchDate, forKey: firstLaunchKey)
        self.mockTrialExpired = false
        self.isProUnlocked = false
        AppLogger.storage.info("试用期已重置为 30 天")
    }

    /// 模拟试用期到期 (供测试使用)
    public func simulateTrialExpired() {
        self.mockTrialExpired = true
        self.isProUnlocked = false
        AppLogger.storage.info("已模拟试用期到期状态")
    }

    // MARK: - StoreKit 交易监听
    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result,
                   transaction.productID == Self.productId {
                    await MainActor.run {
                        self.isProUnlocked = true
                    }
                    await transaction.finish()
                }
            }
        }
    }
}
