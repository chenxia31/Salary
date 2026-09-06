import SwiftUI
import SalaryTickerCore

public struct PaywallView: View {
    @Bindable var subscriptionStore: SubscriptionStore
    @Environment(\.dismiss) private var dismiss

    // 支付渠道选择: 1 支付宝 (优先默认展示用户收款码), 0 微信支付
    @State private var paymentChannel: Int = 1
    @State private var justActivated: Bool = false

    public init(subscriptionStore: SubscriptionStore = .shared) {
        self.subscriptionStore = subscriptionStore
    }

    public var body: some View {
        VStack(spacing: 16) {
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

            // 图标与标题
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.85), .yellow.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                Text(String(localized: "解锁 SalaryTicker PRO"))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)

                // 试用状态提示
                Text(subscriptionStore.statusBadgeText)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(subscriptionStore.isProUnlocked ? .green : (subscriptionStore.isTrialActive ? .orange : .red))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.quaternary, in: Capsule())
            }

            // 特权列表
            VStack(alignment: .leading, spacing: 8) {
                featureRow(
                    icon: "bolt.fill",
                    color: .mint,
                    title: String(localized: "实时无限制每秒跳动"),
                    desc: String(localized: "精准捕捉每一秒薪资进账，平滑等宽无微颤")
                )

                featureRow(
                    icon: "paintpalette.fill",
                    color: .purple,
                    title: String(localized: "个性化图标与奢华色彩"),
                    desc: String(localized: "8 款精选图标与 7 种高定配色全彩呈现")
                )

                featureRow(
                    icon: "target",
                    color: .orange,
                    title: String(localized: "自由定制生活打工目标"),
                    desc: String(localized: "自定义咖啡、外卖、房租，达标自动点亮")
                )

                featureRow(
                    icon: "sparkles",
                    color: .yellow,
                    title: String(localized: "一次付费，终身享用"),
                    desc: String(localized: "永久使用，后续尊享功能免费全量升级")
                )
            }
            .padding(12)
            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)

            // 二维码支付卡片
            if subscriptionStore.isProUnlocked {
                unlockedSuccessView
            } else {
                qrPaymentCardView
            }

            Divider()

            // 快捷测试调测区（便于体验与审查）
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

                    Button(String(localized: "一键激活 PRO")) {
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
        .frame(width: 380)
        .background(.ultraThinMaterial)
    }

    // 已解锁状态展示
    private var unlockedSuccessView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 38))
                .foregroundStyle(.green)

            Text(String(localized: "已成功解锁永久 PRO 特权"))
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)

            Text(String(localized: "感谢您的支持！所有高定主题与高级功能已全部生效。"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // 二维码扫码支付卡片
    private var qrPaymentCardView: some View {
        VStack(spacing: 12) {
            // 渠道选择器 (支付宝 / 微信)
            Picker("", selection: $paymentChannel) {
                Text(String(localized: "🔵 支付宝支付")).tag(1)
                Text(String(localized: "🟢 微信支付")).tag(0)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)

            // 二维码容器
            VStack(spacing: 8) {
                let currentQRImage: NSImage? = paymentChannel == 1 ? alipayQRImage : wechatQRImage

                if let img = currentQRImage {
                    Image(nsImage: img)
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 145, height: 145)
                        .padding(8)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                } else {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 145, height: 145)
                }

                // 金额与提示
                HStack(spacing: 5) {
                    Image(systemName: paymentChannel == 1 ? "qrcode.viewfinder" : "qrcode")
                        .foregroundStyle(paymentChannel == 1 ? Color.blue : Color.green)

                    Text(String(localized: paymentChannel == 1 ? "支付宝扫码" : "微信扫码"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    Text("¥1.99")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(paymentChannel == 1 ? Color.blue : Color.green)

                    Text(String(localized: "(永久解锁)"))
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
                    Text(String(localized: "我已扫码支付，点击激活"))
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
        .padding(.vertical, 12)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
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

    private func featureRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(desc)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
