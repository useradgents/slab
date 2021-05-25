#if canImport(UIKit)

import Foundation
import CoreGraphics
import CoreImage
import UIKit

public struct QRCode {
    public enum ErrorCorrection: String, CaseIterable, CustomStringConvertible {
        case low
        case medium
        case quarter
        case high
        
        public var description: String {
            switch self {
                case .low: return "7%"
                case .medium: return "15%"
                case .quarter: return "25%"
                case .high: return "30%"
            }
        }
        
        var value: String {
            switch self {
                case .low: return "L"
                case .medium: return "M"
                case .quarter: return "Q"
                case .high: return "H"
            }
        }
    }
    
    let data: Data
    let errorCorrection: ErrorCorrection
    
    public init(_ data: Data, errorCorrection: ErrorCorrection = .low) {
        self.data = data
        self.errorCorrection = errorCorrection
    }
    
    public init?(_ url: URL, errorCorrection: ErrorCorrection = .low) {
        guard let data = url.absoluteString.data(using: .isoLatin1) else { return nil }
        self.data = data
        self.errorCorrection = errorCorrection
    }
    
    public func UIImage(scale: CGFloat = 1, foregroundColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> UIImage? {
        guard let cgImage = cgImage(foregroundColor: foregroundColor, backgroundColor: backgroundColor) else { return nil }
        let size = CGSize(width: CGFloat(cgImage.width) * scale, height: CGFloat(cgImage.height) * scale)
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func pngData(scale: CGFloat = 1, foregroundColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> Data? {
        UIImage(scale: scale, foregroundColor: foregroundColor, backgroundColor: backgroundColor)?.pngData()
    }
    
    public func svg(foregroundColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> Data? {
        guard let cgImage = cgImage() else { return nil }
        guard let provider = cgImage.dataProvider?.data else { return nil }
        guard let data = CFDataGetBytePtr(provider) else { return nil }
        
        var fgColor = "black"
        if let fg = foregroundColor {
            var r = CGFloat(0)
            var g = CGFloat(0)
            var b = CGFloat(0)
            var a = CGFloat(0)
            fg.getRed(&r, green: &g, blue: &b, alpha: &a)
            fgColor = String(format: "#%02x%02x%02x", r, g, b)
        }
        
        var bgColor: String? = nil
        if let bg = backgroundColor {
            var r = CGFloat(0)
            var g = CGFloat(0)
            var b = CGFloat(0)
            var a = CGFloat(0)
            bg.getRed(&r, green: &g, blue: &b, alpha: &a)
            bgColor = String(format: "#%02x%02x%02x", r, g, b)
        }
        
        var svg = """
        <?xml version="1.0" standalone="no"?>
        <svg width="\(cgImage.width-2)px" height="\(cgImage.height-2)px" version="1.1" xmlns="http://www.w3.org/2000/svg">
        """
        
        if let bg = bgColor {
            svg += """
            <rect width="100%" height="100%" fill="\(bg)" />
            """
        }
        
        svg += "<g fill=\"\(fgColor)\" stroke=\"none\">"
        
        (1..<cgImage.height-1).forEach { y in
            (1..<cgImage.width-1).forEach { x in
                let offset = y * cgImage.bytesPerRow + x * cgImage.bitsPerPixel / 8
                if data[offset] == 0 {
                    svg += "  <rect x=\"\(x-1)px\" y=\"\(y-1)px\" width=\"1px\" height=\"1px\" />\n"
                }
            }
        }
        
        svg += "</g>\n</svg>"
        return svg.data(using: .utf8)
    }
    
    public func ascii(pixelOn on: String = "██", off: String = "  ") -> String? {
        guard let cg = cgImage() else { return nil }
        guard let provider = cg.dataProvider?.data else { return nil }
        guard let data = CFDataGetBytePtr(provider) else { return nil }
        
        return (1..<cg.height-1).map { y in
            (1..<cg.width-1).map { x in
                let offset = y * cg.bytesPerRow + x * cg.bitsPerPixel / 8
                return data[offset] == 0 ? on : off
            }.joined()
        }.joined(separator: "\n")
    }
    
    private func cgImage(foregroundColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> CGImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setDefaults()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(errorCorrection.value, forKey: "inputCorrectionLevel")
        
        if foregroundColor == nil && backgroundColor == nil {
            guard let ciImage = filter.outputImage else { return nil }
            return CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent)
        }
        else {
            guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
            colorFilter.setValue(filter.outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(color: foregroundColor ?? .black) , forKey: "inputColor0")
            colorFilter.setValue(CIColor(color: backgroundColor ?? .white), forKey: "inputColor1")
            
            guard let ciImage = colorFilter.outputImage else { return nil }
            return CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent)
        }
    }
}

extension URL {
    public func qrCode(errorCorrection: QRCode.ErrorCorrection = .low) -> QRCode? {
        QRCode(self, errorCorrection: errorCorrection)
    }
}

#endif
