import Foundation
import AppKit

struct IconProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var originalImage: Data?
    var foregroundLayer: Layer
    var backgroundLayer: Layer
    var shadowLayer: Layer
    var brightness: Double
    var contrast: Double
    var saturation: Double
    var badgeText: String?
    var badgeColor: Data?
    var cornerRadius: CGFloat
    var createdAt: Date
    var modifiedAt: Date

    init(id: UUID = UUID(), name: String = "Untitled Icon", originalImage: Data? = nil) {
        self.id = id
        self.name = name
        self.originalImage = originalImage
        self.foregroundLayer = Layer(type: .foreground)
        self.backgroundLayer = Layer(type: .background)
        self.shadowLayer = Layer(type: .shadow)
        self.brightness = 0
        self.contrast = 0
        self.saturation = 0
        self.badgeText = nil
        self.badgeColor = nil
        self.cornerRadius = 0.2237
        self.createdAt = Date()
        self.modifiedAt = Date()
    }

    mutating func updateModifiedDate() {
        self.modifiedAt = Date()
    }

    func originalNSImage() -> NSImage? {
        guard let imageData = originalImage else { return nil }
        return NSImage(data: imageData)
    }
}

extension IconProject {
    static var sample: IconProject {
        IconProject(name: "Sample App Icon")
    }
}
