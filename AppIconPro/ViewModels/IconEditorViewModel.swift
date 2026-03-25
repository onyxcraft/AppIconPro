import Foundation
import AppKit
import Combine

@MainActor
class IconEditorViewModel: ObservableObject {
    @Published var project: IconProject
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var selectedTemplate: Template?
    @Published var previewMode: PreviewMode = .liquidGlass
    @Published var previewContext: PreviewContext = .homeScreen

    private let visionService = VisionService.shared
    private let imageProcessor = ImageProcessor.shared
    private let metalRenderer = MetalRenderer.createDefault()

    init(project: IconProject = IconProject()) {
        self.project = project
    }

    func importImage(_ image: NSImage) async {
        isProcessing = true
        errorMessage = nil

        do {
            project.originalImage = image.tiffRepresentation

            let result = try await visionService.separateForegroundBackground(from: image)

            project.foregroundLayer.image = result.foreground.tiffRepresentation
            project.backgroundLayer.image = result.background.tiffRepresentation

            if let shadowImage = visionService.generateShadowMask(
                from: result.foreground,
                shadowRadius: 10,
                shadowOpacity: 0.3,
                offset: CGSize(width: 0, height: -2)
            ) {
                project.shadowLayer.image = shadowImage.tiffRepresentation
            }

            project.updateModifiedDate()

        } catch {
            errorMessage = "Failed to process image: \(error.localizedDescription)"
        }

        isProcessing = false
    }

    func applyTemplate(_ template: Template) {
        selectedTemplate = template

        if let backgroundImage = template.generateBackground(size: NSSize(width: 1024, height: 1024)) {
            project.backgroundLayer.image = backgroundImage.tiffRepresentation
            project.updateModifiedDate()
        }
    }

    func updateForegroundOffset(x: CGFloat, y: CGFloat) {
        project.foregroundLayer.offsetX = x
        project.foregroundLayer.offsetY = y
        project.updateModifiedDate()
    }

    func updateForegroundScale(_ scale: CGFloat) {
        project.foregroundLayer.scale = scale
        project.updateModifiedDate()
    }

    func updateBackgroundBlur(_ radius: CGFloat) {
        project.backgroundLayer.blurRadius = radius
        project.updateModifiedDate()
    }

    func updateShadow(radius: CGFloat, opacity: CGFloat, offsetX: CGFloat, offsetY: CGFloat) {
        project.shadowLayer.shadowRadius = radius
        project.shadowLayer.shadowOpacity = opacity
        project.shadowLayer.offsetX = offsetX
        project.shadowLayer.offsetY = offsetY
        project.updateModifiedDate()
    }

    func updateAdjustments(brightness: Double, contrast: Double, saturation: Double) {
        project.brightness = brightness
        project.contrast = contrast
        project.saturation = saturation
        project.updateModifiedDate()
    }

    func updateBadge(text: String?, color: NSColor?) {
        project.badgeText = text
        if let color = color {
            project.badgeColor = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        }
        project.updateModifiedDate()
    }

    func generatePreview(size: CGSize = CGSize(width: 512, height: 512)) -> NSImage? {
        guard let foreground = project.foregroundLayer.nsImage() else {
            return nil
        }

        let background = project.backgroundLayer.nsImage()

        switch previewMode {
        case .liquidGlass:
            return metalRenderer?.renderLiquidGlassPreview(
                foreground: foreground,
                background: background,
                foregroundOffset: CGPoint(x: project.foregroundLayer.offsetX, y: project.foregroundLayer.offsetY),
                foregroundScale: project.foregroundLayer.scale,
                backgroundBlur: project.backgroundLayer.blurRadius,
                shadowRadius: project.shadowLayer.shadowRadius,
                shadowOpacity: project.shadowLayer.shadowOpacity,
                size: size
            )

        case .traditional:
            return imageProcessor.composeLayers(
                background: background,
                foreground: foreground,
                shadow: project.shadowLayer.nsImage(),
                foregroundOffset: CGPoint(x: project.foregroundLayer.offsetX, y: project.foregroundLayer.offsetY),
                foregroundScale: project.foregroundLayer.scale,
                shadowOffset: CGPoint(x: project.shadowLayer.offsetX, y: project.shadowLayer.offsetY),
                shadowOpacity: project.shadowLayer.shadowOpacity,
                size: size
            )
        }
    }

    func exportProject(to url: URL, configuration: ExportConfiguration) async throws {
        isProcessing = true
        errorMessage = nil

        do {
            try await ExportService.shared.exportProject(project, configuration: configuration, to: url)
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
            throw error
        }

        isProcessing = false
    }

    func resetProject() {
        project = IconProject()
        selectedTemplate = nil
        errorMessage = nil
    }
}

enum PreviewMode {
    case liquidGlass
    case traditional
}

enum PreviewContext {
    case homeScreen
    case settings
    case appStore
    case notification
}
