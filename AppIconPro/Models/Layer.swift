import Foundation
import AppKit

enum LayerType: Codable {
    case foreground
    case background
    case shadow
}

struct Layer: Identifiable, Codable {
    let id: UUID
    let type: LayerType
    var image: Data?
    var offsetX: CGFloat
    var offsetY: CGFloat
    var scale: CGFloat
    var opacity: CGFloat
    var blurRadius: CGFloat
    var shadowRadius: CGFloat
    var shadowOpacity: CGFloat
    var shadowOffsetX: CGFloat
    var shadowOffsetY: CGFloat

    init(id: UUID = UUID(), type: LayerType, image: Data? = nil) {
        self.id = id
        self.type = type
        self.image = image
        self.offsetX = 0
        self.offsetY = 0
        self.scale = 1.0
        self.opacity = 1.0
        self.blurRadius = 0
        self.shadowRadius = type == .shadow ? 10 : 0
        self.shadowOpacity = type == .shadow ? 0.3 : 0
        self.shadowOffsetX = 0
        self.shadowOffsetY = type == .shadow ? -2 : 0
    }

    func nsImage() -> NSImage? {
        guard let imageData = image else { return nil }
        return NSImage(data: imageData)
    }
}
