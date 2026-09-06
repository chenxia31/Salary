import SwiftUI
import SalaryTickerCore

public struct MilestoneView: View {
    let milestones: [MilestoneItem]
    let todayEarnings: Double
    let currencySymbol: String
    var onEditTap: (() -> Void)? = nil

    public init(
        milestones: [MilestoneItem],
        todayEarnings: Double,
        currencySymbol: String,
        onEditTap: (() -> Void)? = nil
    ) {
        self.milestones = milestones
        self.todayEarnings = todayEarnings
        self.currencySymbol = currencySymbol
        self.onEditTap = onEditTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 4) {
                    Text(String(localized: "今日生活小目标"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    if let onEditTap {
                        Button {
                            onEditTap()
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help(String(localized: "自定义生活小目标"))
                    }
                }

                Spacer()

                let completedCount = milestones.filter { todayEarnings >= $0.targetAmount }.count
                Text("\(completedCount)/\(milestones.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(milestones) { item in
                        milestoneBadge(item: item)
                    }
                }
            }
        }
    }

    private func milestoneBadge(item: MilestoneItem) -> some View {
        let isReached = todayEarnings >= item.targetAmount
        let progress = min(1.0, max(0.0, todayEarnings / max(item.targetAmount, 1.0)))

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: item.icon)
                    .font(.caption)
                    .foregroundStyle(isReached ? .orange : .secondary)

                Text(item.title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isReached ? .primary : .secondary)

                Spacer(minLength: 4)

                if isReached {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            Text(SalaryEngine.formatCurrency(item.targetAmount, symbol: currencySymbol, precision: 0))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isReached ? .primary : .secondary)

            // 进度小条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                        .frame(height: 3)

                    Capsule()
                        .fill(isReached ? Color.green : Color.orange)
                        .frame(width: geo.size.width * progress, height: 3)
                }
            }
            .frame(height: 3)
        }
        .frame(width: 110)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isReached ? AnyShapeStyle(.quaternary.opacity(0.8)) : AnyShapeStyle(.quaternary.opacity(0.4)))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isReached ? Color.green.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 0.5)
        }
    }
}
