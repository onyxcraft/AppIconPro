import Foundation
import Metal
import MetalKit
import AppKit

class MetalRenderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let library: MTLLibrary
    var pipelineState: MTLRenderPipelineState?

    init?(device: MTLDevice) {
        self.device = device

        guard let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        self.commandQueue = commandQueue

        guard let library = device.makeDefaultLibrary() else {
            return nil
        }
        self.library = library

        super.init()

        setupPipeline()
    }

    private func setupPipeline() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }

    func renderLiquidGlassPreview(foreground: NSImage?, background: NSImage?,
                                 foregroundOffset: CGPoint, foregroundScale: CGFloat,
                                 backgroundBlur: CGFloat, shadowRadius: CGFloat,
                                 shadowOpacity: CGFloat, size: CGSize) -> NSImage? {
        let finalImage = NSImage(size: size)
        finalImage.lockFocus()
        defer { finalImage.unlockFocus() }

        guard let context = NSGraphicsContext.current?.cgContext else {
            return nil
        }

        let rect = CGRect(origin: .zero, size: size)

        if let background = background {
            var processedBackground = background
            if backgroundBlur > 0 {
                processedBackground = ImageProcessor.shared.applyGaussianBlur(
                    to: background,
                    radius: backgroundBlur
                ) ?? background
            }

            processedBackground.draw(in: rect,
                                   from: NSRect(origin: .zero, size: background.size),
                                   operation: .copy,
                                   fraction: 1.0)
        } else {
            context.setFillColor(NSColor(white: 0.95, alpha: 1.0).cgColor)
            context.fill(rect)
        }

        applyGlassEffect(context: context, rect: rect)

        if let foreground = foreground, shadowRadius > 0, shadowOpacity > 0 {
            let scaledSize = CGSize(width: size.width * foregroundScale,
                                   height: size.height * foregroundScale)
            let foregroundRect = NSRect(x: (size.width - scaledSize.width) / 2 + foregroundOffset.x,
                                       y: (size.height - scaledSize.height) / 2 + foregroundOffset.y,
                                       width: scaledSize.width,
                                       height: scaledSize.height)

            context.saveGState()
            let shadow = NSShadow()
            shadow.shadowOffset = NSSize(width: 0, height: -2)
            shadow.shadowBlurRadius = shadowRadius
            shadow.shadowColor = NSColor.black.withAlphaComponent(shadowOpacity)
            shadow.set()

            foreground.draw(in: foregroundRect,
                          from: NSRect(origin: .zero, size: foreground.size),
                          operation: .sourceOver,
                          fraction: 1.0)

            context.restoreGState()
        } else if let foreground = foreground {
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

        return finalImage
    }

    private func applyGlassEffect(context: CGContext, rect: CGRect) {
        context.saveGState()

        let highlightGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                NSColor.white.withAlphaComponent(0.15).cgColor,
                NSColor.white.withAlphaComponent(0.05).cgColor
            ] as CFArray,
            locations: [0.0, 1.0]
        )

        if let gradient = highlightGradient {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.midX, y: rect.maxY),
                end: CGPoint(x: rect.midX, y: rect.midY),
                options: []
            )
        }

        context.setFillColor(NSColor.white.withAlphaComponent(0.08).cgColor)
        context.fill(rect)

        context.restoreGState()
    }

    func createPreviewTexture(from image: NSImage) -> MTLTexture? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: cgImage.width,
            height: cgImage.height,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .renderTarget]

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * cgImage.width
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))

        if let data = context.data {
            texture.replace(
                region: MTLRegionMake2D(0, 0, cgImage.width, cgImage.height),
                mipmapLevel: 0,
                withBytes: data,
                bytesPerRow: bytesPerRow
            )
        }

        return texture
    }
}

extension MetalRenderer {
    static func createDefault() -> MetalRenderer? {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        return MetalRenderer(device: device)
    }
}
