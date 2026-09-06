import SwiftUI
import SalaryTickerCore

public struct StatusBarLabelView: View {
    @Bindable var viewModel: StatusBarViewModel
    @Bindable var settingsStore: SalarySettingsStore

    public init(viewModel: StatusBarViewModel) {
        self.viewModel = viewModel
        self.settingsStore = viewModel.settingsStore
    }

    public var body: some View {
        HStack(spacing: 5) {
            // 使用适配 macOS MenuBar 的原生 NSImage 渲染图标与颜色
            Image(nsImage: viewModel.statusIconNSImage)

            if !viewModel.statusText.isEmpty {
                Text(viewModel.statusText)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
            }
        }
    }
}
