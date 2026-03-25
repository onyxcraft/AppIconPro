import Foundation
import Vision
import AppKit
import CoreImage

class VisionService {
    static let shared = VisionService()

    private init() {}

    func separateForegroundBackground(from image: NSImage) async throws -> (foreground: NSImage, background: NSImage) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw VisionServiceError.invalidImage
        }

        let request = VNGenerateForegroundInstanceMaskRequest()

        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])

                    guard let result = request.results?.first else {
                        continuation.resume(throwing: VisionServiceError.noMaskGenerated)
                        return
                    }

                    let maskPixelBuffer = result.pixelBuffer
                    let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer)

                    let originalCIImage = CIImage(cgImage: cgImage)

                    let scaleX = originalCIImage.extent.width / maskCIImage.extent.width
                    let scaleY = originalCIImage.extent.height / maskCIImage.extent.height
                    let scaledMask = maskCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

                    let context = CIContext()

                    let blendFilter = CIFilter(name: "CIBlendWithMask")!
                    blendFilter.setValue(originalCIImage, forKey: kCIInputImageKey)
                    blendFilter.setValue(CIImage(color: .clear).cropped(to: originalCIImage.extent), forKey: kCIInputBackgroundImageKey)
                    blendFilter.setValue(scaledMask, forKey: kCIInputMaskImageKey)

                    guard let foregroundCIImage = blendFilter.outputImage,
                          let foregroundCGImage = context.createCGImage(foregroundCIImage, from: foregroundCIImage.extent) else {
                        continuation.resume(throwing: VisionServiceError.processingFailed)
                        return
                    }

                    let foregroundImage = NSImage(cgImage: foregroundCGImage, size: image.size)

                    let invertFilter = CIFilter(name: "CIColorInvert")!
                    invertFilter.setValue(scaledMask, forKey: kCIInputImageKey)
                    guard let invertedMask = invertFilter.outputImage else {
                        continuation.resume(throwing: VisionServiceError.processingFailed)
                        return
                    }

                    let backgroundBlendFilter = CIFilter(name: "CIBlendWithMask")!
                    backgroundBlendFilter.setValue(originalCIImage, forKey: kCIInputImageKey)
                    backgroundBlendFilter.setValue(CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: 1)).cropped(to: originalCIImage.extent), forKey: kCIInputBackgroundImageKey)
                    backgroundBlendFilter.setValue(invertedMask, forKey: kCIInputMaskImageKey)

                    guard let backgroundCIImage = backgroundBlendFilter.outputImage,
                          let backgroundCGImage = context.createCGImage(backgroundCIImage, from: backgroundCIImage.extent) else {
                        continuation.resume(throwing: VisionServiceError.processingFailed)
                        return
                    }

                    let backgroundImage = NSImage(cgImage: backgroundCGImage, size: image.size)

                    continuation.resume(returning: (foregroundImage, backgroundImage))
                } catch {
                    continuation.resume(throwing: VisionServiceError.visionRequestFailed(error))
                }
            }
        }
    }

    func generateShadowMask(from foregroundImage: NSImage, shadowRadius: CGFloat, shadowOpacity: CGFloat, offset: CGSize) -> NSImage? {
        guard let cgImage = foregroundImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let ciImage = CIImage(cgImage: cgImage)

        let shadowFilter = CIFilter(name: "CIGaussianBlur")!
        shadowFilter.setValue(ciImage, forKey: kCIInputImageKey)
        shadowFilter.setValue(shadowRadius, forKey: kCIInputRadiusKey)

        guard var shadowOutput = shadowFilter.outputImage else { return nil }

        shadowOutput = shadowOutput.transformed(by: CGAffineTransform(translationX: offset.width, y: offset.height))

        let colorFilter = CIFilter(name: "CIColorMatrix")!
        colorFilter.setValue(shadowOutput, forKey: kCIInputImageKey)
        colorFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        colorFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(shadowOpacity)), forKey: "inputAVector")

        guard let finalShadow = colorFilter.outputImage else { return nil }

        let context = CIContext()
        let extent = ciImage.extent
        guard let shadowCGImage = context.createCGImage(finalShadow, from: extent) else { return nil }

        return NSImage(cgImage: shadowCGImage, size: foregroundImage.size)
    }
}

enum VisionServiceError: LocalizedError {
    case invalidImage
    case noMaskGenerated
    case processingFailed
    case visionRequestFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .noMaskGenerated:
            return "Failed to generate foreground mask"
        case .processingFailed:
            return "Image processing failed"
        case .visionRequestFailed(let error):
            return "Vision request failed: \(error.localizedDescription)"
        }
    }
}
