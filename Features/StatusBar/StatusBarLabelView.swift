import SwiftUI
import SalaryTickerCore

public struct StatusBarLabelView: View {
    @Bindable var viewModel: StatusBarViewModel

    public init(viewModel: StatusBarViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(spacing: 5) {
            // 自定义状态图标与自选色彩
            Image(systemName: viewModel.currentSettings.statusIcon)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(viewModel.resolvedColor)

            if !viewModel.statusText.isEmpty {
                Text(viewModel.statusText)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
            }
        }
    }
}
