import SwiftUI
import SalaryTickerCore

public struct StatusBarLabelView: View {
    @Bindable var viewModel: StatusBarViewModel

    public init(viewModel: StatusBarViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(spacing: 5) {
            // 状态图标：Apple 风格精致钱币/纸币图标
            Image(systemName: "banknote.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(viewModel.statusDotColor)

            if !viewModel.statusText.isEmpty {
                Text(viewModel.statusText)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
            }
        }
    }
}
