import Foundation
import AppKit
import Combine

@MainActor
class BatchProcessorViewModel: ObservableObject {
    @Published var projects: [IconProject] = []
    @Published var isProcessing: Bool = false
    @Published var currentProgress: Double = 0
    @Published var currentProjectIndex: Int = 0
    @Published var errorMessage: String?
    @Published var completedCount: Int = 0

    private let visionService = VisionService.shared
    private let exportService = ExportService.shared

    func importImages(_ images: [NSImage]) async {
        isProcessing = true
        errorMessage = nil
        projects.removeAll()
        currentProgress = 0
        completedCount = 0

        for (index, image) in images.enumerated() {
            currentProjectIndex = index

            do {
                var project = IconProject(name: "Icon \(index + 1)")
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

                projects.append(project)
                completedCount += 1
                currentProgress = Double(completedCount) / Double(images.count)

            } catch {
                errorMessage = "Failed to process image \(index + 1): \(error.localizedDescription)"
            }
        }

        isProcessing = false
    }

    func applyTemplateToAll(_ template: Template) {
        for index in projects.indices {
            if let backgroundImage = template.generateBackground(size: NSSize(width: 1024, height: 1024)) {
                projects[index].backgroundLayer.image = backgroundImage.tiffRepresentation
                projects[index].updateModifiedDate()
            }
        }
    }

    func applyAdjustmentsToAll(brightness: Double, contrast: Double, saturation: Double) {
        for index in projects.indices {
            projects[index].brightness = brightness
            projects[index].contrast = contrast
            projects[index].saturation = saturation
            projects[index].updateModifiedDate()
        }
    }

    func exportAll(to baseURL: URL, configuration: ExportConfiguration) async throws {
        isProcessing = true
        errorMessage = nil
        currentProgress = 0
        completedCount = 0

        for (index, project) in projects.enumerated() {
            currentProjectIndex = index

            do {
                let projectFolder = baseURL.appendingPathComponent(project.name)
                try await exportService.exportProject(project, configuration: configuration, to: projectFolder)

                completedCount += 1
                currentProgress = Double(completedCount) / Double(projects.count)

            } catch {
                errorMessage = "Failed to export \(project.name): \(error.localizedDescription)"
            }
        }

        isProcessing = false
    }

    func removeProject(at index: Int) {
        guard index < projects.count else { return }
        projects.remove(at: index)
    }

    func clearAll() {
        projects.removeAll()
        currentProgress = 0
        completedCount = 0
        currentProjectIndex = 0
        errorMessage = nil
    }
}
