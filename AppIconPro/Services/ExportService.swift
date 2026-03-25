import Foundation
import AppKit

class ExportService {
    static let shared = ExportService()

    private init() {}

    func exportProject(_ project: IconProject, configuration: ExportConfiguration, to url: URL) async throws {
        switch configuration.format {
        case .liquidGlass:
            try await exportLiquidGlass(project, to: url, configuration: configuration)
        case .xcassets:
            try await exportXCAssets(project, to: url, configuration: configuration)
        case .both:
            try await exportLiquidGlass(project, to: url.appendingPathComponent("LiquidGlass.icon"), configuration: configuration)
            try await exportXCAssets(project, to: url.appendingPathComponent("AppIcon.xcassets"), configuration: configuration)
        }
    }

    private func exportLiquidGlass(_ project: IconProject, to url: URL, configuration: ExportConfiguration) async throws {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        let sizes: [CGFloat] = [120, 180, 240, 360]

        for size in sizes {
            let targetSize = CGSize(width: size, height: size)

            if let foregroundImage = project.foregroundLayer.nsImage() {
                var processedForeground = foregroundImage
                if configuration.roundedCorners {
                    processedForeground = ImageProcessor.shared.addRoundedCorners(
                        to: processedForeground,
                        cornerRadius: configuration.cornerRadius
                    ) ?? processedForeground
                }

                if let resized = ImageProcessor.shared.resize(image: processedForeground, to: targetSize),
                   let pngData = resized.pngData() {
                    let filename = url.appendingPathComponent("foreground-\(Int(size)).png")
                    try pngData.write(to: filename)
                }
            }

            if let backgroundImage = project.backgroundLayer.nsImage() {
                var processedBackground = backgroundImage

                if project.backgroundLayer.blurRadius > 0 {
                    processedBackground = ImageProcessor.shared.applyGaussianBlur(
                        to: processedBackground,
                        radius: project.backgroundLayer.blurRadius
                    ) ?? processedBackground
                }

                if let resized = ImageProcessor.shared.resize(image: processedBackground, to: targetSize),
                   let pngData = resized.pngData() {
                    let filename = url.appendingPathComponent("background-\(Int(size)).png")
                    try pngData.write(to: filename)
                }
            }

            if let shadowImage = project.shadowLayer.nsImage() {
                if let resized = ImageProcessor.shared.resize(image: shadowImage, to: targetSize),
                   let pngData = resized.pngData() {
                    let filename = url.appendingPathComponent("shadow-\(Int(size)).png")
                    try pngData.write(to: filename)
                }
            }
        }

        let contentsJSON: [String: Any] = [
            "info": [
                "version": 1,
                "author": "AppIconPro"
            ],
            "layers": [
                ["name": "foreground", "type": "foreground"],
                ["name": "background", "type": "background"],
                ["name": "shadow", "type": "shadow"]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: contentsJSON, options: .prettyPrinted)
        try jsonData.write(to: url.appendingPathComponent("Contents.json"))
    }

    private func exportXCAssets(_ project: IconProject, to url: URL, configuration: ExportConfiguration) async throws {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }

        let appIconSetURL = url.appendingPathComponent("AppIcon.appiconset")
        try fileManager.createDirectory(at: appIconSetURL, withIntermediateDirectories: true)

        let compositeImage = try await generateCompositeImage(from: project, configuration: configuration)

        var imagesJSON: [[String: Any]] = []

        for iconSize in IconSize.allSizes {
            let size = CGSize(width: iconSize.pixelSize, height: iconSize.pixelSize)

            guard var resized = ImageProcessor.shared.resize(image: compositeImage, to: size) else {
                continue
            }

            if configuration.roundedCorners {
                resized = ImageProcessor.shared.addRoundedCorners(
                    to: resized,
                    cornerRadius: configuration.cornerRadius
                ) ?? resized
            }

            if let pngData = resized.pngData() {
                let filename = "\(iconSize.name)-\(Int(iconSize.pixelSize))@\(iconSize.scale)x.png"
                try pngData.write(to: appIconSetURL.appendingPathComponent(filename))

                imagesJSON.append([
                    "filename": filename,
                    "idiom": iconSize.idiom,
                    "scale": "\(iconSize.scale)x",
                    "size": "\(Int(iconSize.size))x\(Int(iconSize.size))"
                ])
            }
        }

        let contentsJSON: [String: Any] = [
            "images": imagesJSON,
            "info": [
                "version": 1,
                "author": "AppIconPro"
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: contentsJSON, options: .prettyPrinted)
        try jsonData.write(to: appIconSetURL.appendingPathComponent("Contents.json"))
    }

    private func generateCompositeImage(from project: IconProject, configuration: ExportConfiguration) async throws -> NSImage {
        let baseSize = CGSize(width: 1024, height: 1024)

        var backgroundImage = project.backgroundLayer.nsImage()
        if backgroundImage == nil, let originalImage = project.originalNSImage() {
            backgroundImage = originalImage
        }

        if let background = backgroundImage, project.backgroundLayer.blurRadius > 0 {
            backgroundImage = ImageProcessor.shared.applyGaussianBlur(
                to: background,
                radius: project.backgroundLayer.blurRadius
            )
        }

        var foregroundImage = project.foregroundLayer.nsImage()
        if foregroundImage == nil, let originalImage = project.originalNSImage() {
            foregroundImage = originalImage
        }

        if let foreground = foregroundImage {
            foregroundImage = ImageProcessor.shared.applyAdjustments(
                to: foreground,
                brightness: project.brightness,
                contrast: project.contrast,
                saturation: project.saturation
            )
        }

        let shadowImage = project.shadowLayer.nsImage()

        let foregroundOffset = CGPoint(
            x: project.foregroundLayer.offsetX,
            y: project.foregroundLayer.offsetY
        )
        let shadowOffset = CGPoint(
            x: project.shadowLayer.offsetX,
            y: project.shadowLayer.offsetY
        )

        guard var composite = ImageProcessor.shared.composeLayers(
            background: backgroundImage,
            foreground: foregroundImage,
            shadow: shadowImage,
            foregroundOffset: foregroundOffset,
            foregroundScale: project.foregroundLayer.scale,
            shadowOffset: shadowOffset,
            shadowOpacity: project.shadowLayer.shadowOpacity,
            size: baseSize
        ) else {
            throw ExportError.compositionFailed
        }

        if let badgeText = project.badgeText, !badgeText.isEmpty {
            let badgeColor: NSColor
            if let colorData = project.badgeColor,
               let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
                badgeColor = color
            } else {
                badgeColor = .systemRed
            }

            composite = ImageProcessor.shared.addBadge(
                to: composite,
                text: badgeText,
                color: badgeColor
            ) ?? composite
        }

        return composite
    }

    func exportBatch(_ projects: [IconProject], configuration: ExportConfiguration, to baseURL: URL) async throws {
        for project in projects {
            let projectFolder = baseURL.appendingPathComponent(project.name)
            try await exportProject(project, configuration: configuration, to: projectFolder)
        }
    }
}

enum ExportError: LocalizedError {
    case compositionFailed
    case invalidProject
    case fileSystemError

    var errorDescription: String? {
        switch self {
        case .compositionFailed:
            return "Failed to compose final image"
        case .invalidProject:
            return "Invalid project data"
        case .fileSystemError:
            return "File system operation failed"
        }
    }
}

extension NSImage {
    func pngData() -> Data? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .png, properties: [:])
    }
}
