import SwiftUI
import SalaryTickerCore

public struct StatsBreakdownView: View {
    let settings: SalarySettings
    let ratePerSecond: Double
    let ratePerMinute: Double
    let ratePerHour: Double

    public init(
        settings: SalarySettings,
        ratePerSecond: Double,
        ratePerMinute: Double,
        ratePerHour: Double
    ) {
        self.settings = settings
        self.ratePerSecond = ratePerSecond
        self.ratePerMinute = ratePerMinute
        self.ratePerHour = ratePerHour
    }

    public var body: some View {
        HStack(spacing: 10) {
            rateCard(
                title: String(localized: "每秒入账"),
                amount: SalaryEngine.formatRatePerSecond(ratePerSecond, symbol: settings.currencySymbol, precision: 3),
                icon: "bolt.fill",
                color: .mint
            )

            rateCard(
                title: String(localized: "每分流速"),
                amount: SalaryEngine.formatCurrency(ratePerMinute, symbol: settings.currencySymbol, precision: 2),
                icon: "timer",
                color: .cyan
            )

            rateCard(
                title: String(localized: "每小时薪"),
                amount: SalaryEngine.formatCurrency(ratePerHour, symbol: settings.currencySymbol, precision: 1),
                icon: "clock.badge.checkmark.fill",
                color: .blue
            )
        }
    }

    private func rateCard(title: String, amount: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            Text(amount)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.quaternary.opacity(0.6))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
        }
    }
}
