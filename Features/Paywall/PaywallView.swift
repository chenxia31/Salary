import SwiftUI
import SalaryTickerCore

public struct PaywallView: View {
    @Bindable var subscriptionStore: SubscriptionStore
    @Environment(\.dismiss) private var dismiss

    public init(subscriptionStore: SubscriptionStore = .shared) {
        self.subscriptionStore = subscriptionStore
    }

    public var body: some View {
        VStack(spacing: 20) {
            // 顶部关闭按钮
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 14)
            .padding(.horizontal, 16)

            // 图标与标题
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.8), .yellow.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                Text(String(localized: "解锁 SalaryTicker PRO"))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                // 试用状态提示
                Text(subscriptionStore.statusBadgeText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(subscriptionStore.isProUnlocked ? .green : (subscriptionStore.isTrialActive ? .orange : .red))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }

            // 特权列表
            VStack(alignment: .leading, spacing: 12) {
                featureRow(
                    icon: "bolt.fill",
                    color: .mint,
                    title: String(localized: "实时无限制每秒跳动"),
                    desc: String(localized: "精准捕捉每一秒薪资进账，极低功耗平滑无抖动")
                )

                featureRow(
                    icon: "paintpalette.fill",
                    color: .purple,
                    title: String(localized: "个性化图标与奢华色彩"),
                    desc: String(localized: "支持 8 款精选状态栏图标与 7 种高定配色主题")
                )

                featureRow(
                    icon: "target",
                    color: .orange,
                    title: String(localized: "自由定制生活打工目标"),
                    desc: String(localized: "自定义咖啡、外卖、房租、数码愿望清单，实时点亮")
                )

                featureRow(
                    icon: "sparkles",
                    color: .yellow,
                    title: String(localized: "后续尊享功能全量升级"),
                    desc: String(localized: "单次付费，终身受用，终身免费获得新版本更新")
                )
            }
            .padding(16)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)

            // 价格与支付按钮
            VStack(spacing: 8) {
                if subscriptionStore.isProUnlocked {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text(String(localized: "您已拥有永久 PRO 特权"))
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 8)
                } else {
                    Button {
                        subscriptionStore.unlockProDirectly()
                    } label: {
                        HStack(spacing: 6) {
                            Text(String(localized: "立即支付 ¥1.99 解锁"))
                                .font(.headline.weight(.bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .controlSize(.large)

                    Text(String(localized: "30天免费试用 · 仅需 ¥1.99 · 单次买断永久使用"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    Button(String(localized: "恢复购买")) {
                        Task {
                            await subscriptionStore.restorePurchases()
                        }
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)

            Divider()

            // 快捷测试调测区（便于评审与体验）
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "🛠 体验与测试工具箱"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Button(String(localized: "重置 30 天试用")) {
                        subscriptionStore.resetTrial()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)

                    Button(String(localized: "模拟试用到期")) {
                        subscriptionStore.simulateTrialExpired()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)

                    Button(String(localized: "快捷激活 PRO")) {
                        subscriptionStore.unlockProDirectly()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: 390)
        .background(.ultraThinMaterial)
    }

    private func featureRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(desc)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
