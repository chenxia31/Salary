import SwiftUI
import AppKit
import SalaryTickerCore
import SalaryTickerFeatures

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 配置为纯菜单栏辅助应用：不在 Dock 显示大图标，不显示默认空白窗口
        NSApplication.shared.setActivationPolicy(.accessory)
        AppLogger.app.info("SalaryTicker 已就绪，状态栏常驻模式启动成功")
    }
}

@main
struct SalaryTickerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var settingsStore: SalarySettingsStore
    @State private var viewModel: StatusBarViewModel

    init() {
        let store = SalarySettingsStore()
        _settingsStore = State(initialValue: store)
        _viewModel = State(initialValue: StatusBarViewModel(settingsStore: store))
    }

    var body: some Scene {
        MenuBarExtra {
            DashboardView(viewModel: viewModel)
        } label: {
            StatusBarLabelView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
