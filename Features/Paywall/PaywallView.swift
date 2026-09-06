import SwiftUI
import SalaryTickerCore

/// 赞助档位模型
public struct SponsorTier: Identifiable, Equatable {
    public let id: Int
    public let price: String
    public let title: String
    public let note: String
    public let icon: String
    public let color: Color

    public init(id: Int, price: String, title: String, note: String, icon: String, color: Color) {
        self.id = id
        self.price = price
        self.title = title
        self.note = note
        self.icon = icon
        self.color = color
    }
}

public struct PaywallView: View {
    @Bindable var subscriptionStore: SubscriptionStore
    @Environment(\.dismiss) private var dismiss

    // 赞助档位列表: 1.99喝杯水, 5.99加鸡腿, 9.99瑞幸咖啡
    private let tiers: [SponsorTier] = [
        SponsorTier(id: 0, price: "¥1.99", title: String(localized: "喝杯水"), note: String(localized: "解渴润喉"), icon: "drop.fill", color: .cyan),
        SponsorTier(id: 1, price: "¥5.99", title: String(localized: "加鸡腿"), note: String(localized: "元气满满"), icon: "flame.fill", color: .orange),
        SponsorTier(id: 2, price: "¥9.99", title: String(localized: "瑞幸咖啡"), note: String(localized: "灵感飞扬"), icon: "cup.and.saucer.fill", color: .brown)
    ]

    // 当前选中的赞助档位
    @State private var selectedTierIndex: Int = 0
    // 支付渠道: 1 支付宝 (优先默认展示用户收款码), 0 微信支付
    @State private var paymentChannel: Int = 1
    @State private var justActivated: Bool = false

    public init(subscriptionStore: SubscriptionStore = .shared) {
        self.subscriptionStore = subscriptionStore
    }

    private var currentTier: SponsorTier {
        tiers[selectedTierIndex]
    }

    public var body: some View {
        VStack(spacing: 14) {
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
            .padding(.top, 12)
            .padding(.horizontal, 16)

            // 头部：爱心与赞助寄语
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.red.opacity(0.85), .orange.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                Text(String(localized: "赞助开发者 · 解锁全部特权"))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)

                Text(String(localized: "每一份打工人之间的支持，都是持续迭代的原动力 ❤️"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                // 试用状态提示
                Text(subscriptionStore.statusBadgeText)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(subscriptionStore.isProUnlocked ? .green : (subscriptionStore.isTrialActive ? .orange : .red))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.quaternary, in: Capsule())
            }

            // 三档赞助金额选择卡片
            HStack(spacing: 10) {
                ForEach(tiers) { tier in
                    sponsorTierCard(tier: tier, isSelected: selectedTierIndex == tier.id)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.25)) {
                                selectedTierIndex = tier.id
                            }
                        }
                }
            }
            .padding(.horizontal, 16)

            // 二维码扫码支付卡片
            if subscriptionStore.isProUnlocked {
                unlockedSuccessView
            } else {
                qrPaymentCardView
            }

            // 特权简述行
            HStack(spacing: 16) {
                Label(String(localized: "8 款高定图标"), systemImage: "sparkles")
                Label(String(localized: "7 款全彩配色"), systemImage: "paintpalette.fill")
                Label(String(localized: "生活目标定制"), systemImage: "target")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Divider()

            // 快捷测试调测区（便于体验与审查）
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "🛠 体验与测试工具箱"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Button(String(localized: "重置试用")) {
                        subscriptionStore.resetTrial()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)

                    Button(String(localized: "模拟到期")) {
                        subscriptionStore.simulateTrialExpired()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)

                    Button(String(localized: "快捷激活特权")) {
                        withAnimation(.spring(duration: 0.35)) {
                            subscriptionStore.unlockProDirectly()
                            justActivated = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .frame(width: 390)
        .background(.ultraThinMaterial)
    }

    // 单个赞助档位卡片
    private func sponsorTierCard(tier: SponsorTier, isSelected: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: tier.icon)
                .font(.title3)
                .foregroundStyle(tier.color)

            Text(tier.price)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)

            Text(tier.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)

            Text(tier.note)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? tier.color.opacity(0.12) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? tier.color : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
    }

    // 二维码扫码支付卡片
    private var qrPaymentCardView: some View {
        VStack(spacing: 10) {
            // 渠道选择器 (支付宝 / 微信)
            Picker("", selection: $paymentChannel) {
                Text(String(localized: "🔵 支付宝扫码")).tag(1)
                Text(String(localized: "🟢 微信支付")).tag(0)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)

            // 二维码容器
            VStack(spacing: 6) {
                let currentQRImage: NSImage? = paymentChannel == 1 ? alipayQRImage : wechatQRImage

                if let img = currentQRImage {
                    Image(nsImage: img)
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .padding(6)
                        .background(.white, in: RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 2)
                } else {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 140, height: 140)
                }

                // 金额与提示
                HStack(spacing: 4) {
                    Image(systemName: currentTier.icon)
                        .foregroundStyle(currentTier.color)

                    Text(String(localized: "赞助意向："))
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("\(currentTier.price) · \(currentTier.title)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(currentTier.color)

                    Text(String(localized: "(任意赞助均可激活)"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // 扫码后激活按钮
            Button {
                withAnimation(.spring(duration: 0.35)) {
                    subscriptionStore.unlockProDirectly()
                    justActivated = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    Text(String(localized: "我已完成赞助，点击激活全部特权"))
                        .font(.subheadline.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(paymentChannel == 1 ? .blue : .green)
            .controlSize(.regular)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // 已解锁状态展示
    private var unlockedSuccessView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 36))
                .foregroundStyle(.green)

            Text(String(localized: "已成功激活永久 PRO 特权"))
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)

            Text(String(localized: "非常感谢您的暖心赞助！您已成为 SalaryTicker 尊贵赞助者，所有高定主题与功能终身开放。"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    /// 用户专属支付宝收款码图片
    private var alipayQRImage: NSImage? {
        if let url = Bundle.main.url(forResource: "alipay_qr", withExtension: "jpg"),
           let img = NSImage(contentsOf: url) {
            return img
        }
        if let img = NSImage(named: "alipay_qr") {
            return img
        }
        if let devImg = NSImage(contentsOfFile: "Resources/alipay_qr.jpg") {
            return devImg
        }
        return QRCodeGenerator.generate(from: "https://qr.alipay.com/fkx13384rierygpezadhk2e", size: 150)
    }

    /// 微信支付二维码图片
    private var wechatQRImage: NSImage? {
        return QRCodeGenerator.generate(from: "https://github.com/chenxia31/Salary#wechat-pay", size: 150)
    }
}
