import Foundation
import AppKit
import CoreImage

class ImageProcessor {
    static let shared = ImageProcessor()

    private init() {}

    func applyAdjustments(to image: NSImage, brightness: Double, contrast: Double, saturation: Double) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        var ciImage = CIImage(cgImage: cgImage)

        if brightness != 0 {
            let brightnessFilter = CIFilter(name: "CIColorControls")!
            brightnessFilter.setValue(ciImage, forKey: kCIInputImageKey)
            brightnessFilter.setValue(brightness, forKey: kCIInputBrightnessKey)
            ciImage = brightnessFilter.outputImage ?? ciImage
        }

        if contrast != 0 {
            let contrastFilter = CIFilter(name: "CIColorControls")!
            contrastFilter.setValue(ciImage, forKey: kCIInputImageKey)
            contrastFilter.setValue(1.0 + contrast, forKey: kCIInputContrastKey)
            ciImage = contrastFilter.outputImage ?? ciImage
        }

        if saturation != 0 {
            let saturationFilter = CIFilter(name: "CIColorControls")!
            saturationFilter.setValue(ciImage, forKey: kCIInputImageKey)
            saturationFilter.setValue(1.0 + saturation, forKey: kCIInputSaturationKey)
            ciImage = saturationFilter.outputImage ?? ciImage
        }

        let context = CIContext()
        guard let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        return NSImage(cgImage: outputCGImage, size: image.size)
    }

    func applyGaussianBlur(to image: NSImage, radius: CGFloat) -> NSImage? {
        guard radius > 0 else { return image }

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let ciImage = CIImage(cgImage: cgImage)
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(radius, forKey: kCIInputRadiusKey)

        guard let outputImage = blurFilter.outputImage else { return nil }

        let context = CIContext()
        guard let outputCGImage = context.createCGImage(outputImage, from: ciImage.extent) else {
            return nil
        }

        return NSImage(cgImage: outputCGImage, size: image.size)
    }

    func resize(image: NSImage, to size: CGSize) -> NSImage? {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        defer { newImage.unlockFocus() }

        image.draw(in: NSRect(origin: .zero, size: size),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)

        return newImage
    }

    func addRoundedCorners(to image: NSImage, cornerRadius: CGFloat) -> NSImage? {
        let size = image.size
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        defer { newImage.unlockFocus() }

        guard let context = NSGraphicsContext.current?.cgContext else { return nil }

        let rect = CGRect(origin: .zero, size: size)
        let radius = min(size.width, size.height) * cornerRadius

        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        context.addPath(path.cgPath)
        context.clip()

        image.draw(in: rect)

        return newImage
    }

    func addBadge(to image: NSImage, text: String, color: NSColor, position: BadgePosition = .topRight) -> NSImage? {
        let size = image.size
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        defer { newImage.unlockFocus() }

        image.draw(in: NSRect(origin: .zero, size: size))

        let badgeSize = min(size.width, size.height) * 0.3
        let badgeRect: NSRect

        switch position {
        case .topRight:
            badgeRect = NSRect(x: size.width - badgeSize, y: size.height - badgeSize,
                             width: badgeSize, height: badgeSize)
        case .topLeft:
            badgeRect = NSRect(x: 0, y: size.height - badgeSize,
                             width: badgeSize, height: badgeSize)
        case .bottomRight:
            badgeRect = NSRect(x: size.width - badgeSize, y: 0,
                             width: badgeSize, height: badgeSize)
        case .bottomLeft:
            badgeRect = NSRect(x: 0, y: 0,
                             width: badgeSize, height: badgeSize)
        }

        let badgePath = NSBezierPath(ovalIn: badgeRect)
        color.setFill()
        badgePath.fill()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: badgeSize * 0.5, weight: .bold),
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraphStyle
        ]

        let textRect = NSRect(x: badgeRect.origin.x,
                            y: badgeRect.origin.y + (badgeSize - badgeSize * 0.5) / 2,
                            width: badgeSize,
                            height: badgeSize * 0.5)

        text.draw(in: textRect, withAttributes: attributes)

        return newImage
    }

    func composeLayers(background: NSImage?, foreground: NSImage?, shadow: NSImage?,
                      foregroundOffset: CGPoint, foregroundScale: CGFloat,
                      shadowOffset: CGPoint, shadowOpacity: CGFloat,
                      size: CGSize) -> NSImage? {
        let compositeImage = NSImage(size: size)
        compositeImage.lockFocus()
        defer { compositeImage.unlockFocus() }

        if let background = background {
            background.draw(in: NSRect(origin: .zero, size: size),
                          from: NSRect(origin: .zero, size: background.size),
                          operation: .copy,
                          fraction: 1.0)
        }

        if let shadow = shadow, shadowOpacity > 0 {
            let shadowRect = NSRect(x: shadowOffset.x,
                                  y: shadowOffset.y,
                                  width: size.width,
                                  height: size.height)
            shadow.draw(in: shadowRect,
                       from: NSRect(origin: .zero, size: shadow.size),
                       operation: .sourceOver,
                       fraction: shadowOpacity)
        }

        if let foreground = foreground {
            let scaledSize = CGSize(width: size.width * foregroundScale,
                                   height: size.height * foregroundScale)
            let foregroundRect = NSRect(x: (size.width - scaledSize.width) / 2 + foregroundOffset.x,
                                       y: (size.height - scaledSize.height) / 2 + foregroundOffset.y,
                                       width: scaledSize.width,
                                       height: scaledSize.height)
            foreground.draw(in: foregroundRect,
                          from: NSRect(origin: .zero, size: foreground.size),
                          operation: .sourceOver,
                          fraction: 1.0)
        }

        return compositeImage
    }

    func createThumbnail(from image: NSImage, size: CGSize = CGSize(width: 128, height: 128)) -> NSImage? {
        return resize(image: image, to: size)
    }
}

enum BadgePosition {
    case topRight
    case topLeft
    case bottomRight
    case bottomLeft
}
