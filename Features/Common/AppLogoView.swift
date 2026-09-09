import SwiftUI
import AppKit

/// 全应用统一品牌 Logo 视图
@MainActor
public struct AppLogoView: View {
    private let size: CGFloat
    private let cornerRadius: CGFloat

    public init(size: CGFloat = 48, cornerRadius: CGFloat? = nil) {
        self.size = size
        self.cornerRadius = cornerRadius ?? (size * 0.22)
    }

    public var body: some View {
        Group {
            if let img = Self.logoImage {
                Image(nsImage: img)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "yensign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.tint)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: size * 0.08, x: 0, y: size * 0.04)
    }

    /// 解析并加载 App Logo 图标，支持 App Bundle、开发目录以及系统应用图标多重回退
    public static var logoImage: NSImage? {
        if let url = Bundle.main.url(forResource: "AppLogo", withExtension: "png"),
           let img = NSImage(contentsOf: url) {
            return img
        }
        if let img = NSImage(named: "AppLogo") {
            return img
        }
        if let devImg = NSImage(contentsOfFile: "Resources/AppLogo.png") {
            return devImg
        }
        if let icon = NSApp.applicationIconImage {
            return icon
        }
        return nil
    }
}
