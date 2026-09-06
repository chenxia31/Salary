import AppKit
import CoreImage

/// 原生 CoreImage 二维码生成工具
public enum QRCodeGenerator {
    /// 根据字符串生成高清 Retina 二维码 NSImage
    @MainActor
    public static func generate(from string: String, size: CGFloat = 200) -> NSImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = string.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }
        let extent = outputImage.extent
        guard extent.width > 0, extent.height > 0 else { return nil }

        let scaleX = size / extent.size.width
        let scaleY = size / extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let rep = NSCIImageRep(ciImage: transformedImage)
        let nsImage = NSImage(size: NSSize(width: size, height: size))
        nsImage.addRepresentation(rep)
        return nsImage
    }
}
