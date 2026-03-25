import Foundation

enum ExportFormat: String, CaseIterable {
    case liquidGlass = "Liquid Glass (.icon)"
    case xcassets = "Xcode Assets (.xcassets)"
    case both = "Both Formats"
}

struct IconSize {
    let name: String
    let size: CGFloat
    let scale: Int
    let idiom: String

    var filename: String {
        if scale == 1 {
            return "\(name).png"
        } else {
            return "\(name)@\(scale)x.png"
        }
    }

    var pixelSize: CGFloat {
        return size * CGFloat(scale)
    }

    static let allSizes: [IconSize] = [
        // iOS App Icon
        IconSize(name: "icon-20", size: 20, scale: 2, idiom: "iphone"),
        IconSize(name: "icon-20", size: 20, scale: 3, idiom: "iphone"),
        IconSize(name: "icon-29", size: 29, scale: 2, idiom: "iphone"),
        IconSize(name: "icon-29", size: 29, scale: 3, idiom: "iphone"),
        IconSize(name: "icon-40", size: 40, scale: 2, idiom: "iphone"),
        IconSize(name: "icon-40", size: 40, scale: 3, idiom: "iphone"),
        IconSize(name: "icon-60", size: 60, scale: 2, idiom: "iphone"),
        IconSize(name: "icon-60", size: 60, scale: 3, idiom: "iphone"),

        // iPad App Icon
        IconSize(name: "icon-20", size: 20, scale: 1, idiom: "ipad"),
        IconSize(name: "icon-20", size: 20, scale: 2, idiom: "ipad"),
        IconSize(name: "icon-29", size: 29, scale: 1, idiom: "ipad"),
        IconSize(name: "icon-29", size: 29, scale: 2, idiom: "ipad"),
        IconSize(name: "icon-40", size: 40, scale: 1, idiom: "ipad"),
        IconSize(name: "icon-40", size: 40, scale: 2, idiom: "ipad"),
        IconSize(name: "icon-76", size: 76, scale: 1, idiom: "ipad"),
        IconSize(name: "icon-76", size: 76, scale: 2, idiom: "ipad"),
        IconSize(name: "icon-83.5", size: 83.5, scale: 2, idiom: "ipad"),

        // App Store
        IconSize(name: "icon-1024", size: 1024, scale: 1, idiom: "ios-marketing"),

        // macOS
        IconSize(name: "icon-16", size: 16, scale: 1, idiom: "mac"),
        IconSize(name: "icon-16", size: 16, scale: 2, idiom: "mac"),
        IconSize(name: "icon-32", size: 32, scale: 1, idiom: "mac"),
        IconSize(name: "icon-32", size: 32, scale: 2, idiom: "mac"),
        IconSize(name: "icon-128", size: 128, scale: 1, idiom: "mac"),
        IconSize(name: "icon-128", size: 128, scale: 2, idiom: "mac"),
        IconSize(name: "icon-256", size: 256, scale: 1, idiom: "mac"),
        IconSize(name: "icon-256", size: 256, scale: 2, idiom: "mac"),
        IconSize(name: "icon-512", size: 512, scale: 1, idiom: "mac"),
        IconSize(name: "icon-512", size: 512, scale: 2, idiom: "mac"),

        // watchOS
        IconSize(name: "icon-24", size: 24, scale: 2, idiom: "watch"),
        IconSize(name: "icon-27.5", size: 27.5, scale: 2, idiom: "watch"),
        IconSize(name: "icon-29", size: 29, scale: 2, idiom: "watch"),
        IconSize(name: "icon-29", size: 29, scale: 3, idiom: "watch"),
        IconSize(name: "icon-40", size: 40, scale: 2, idiom: "watch"),
        IconSize(name: "icon-44", size: 44, scale: 2, idiom: "watch"),
        IconSize(name: "icon-50", size: 50, scale: 2, idiom: "watch"),
        IconSize(name: "icon-86", size: 86, scale: 2, idiom: "watch"),
        IconSize(name: "icon-98", size: 98, scale: 2, idiom: "watch"),
        IconSize(name: "icon-108", size: 108, scale: 2, idiom: "watch"),
    ]

    static let liquidGlassSizes: [IconSize] = [
        IconSize(name: "foreground-120", size: 120, scale: 1, idiom: "universal"),
        IconSize(name: "foreground-180", size: 180, scale: 1, idiom: "universal"),
        IconSize(name: "foreground-240", size: 240, scale: 1, idiom: "universal"),
        IconSize(name: "foreground-360", size: 360, scale: 1, idiom: "universal"),
        IconSize(name: "background-120", size: 120, scale: 1, idiom: "universal"),
        IconSize(name: "background-180", size: 180, scale: 1, idiom: "universal"),
        IconSize(name: "background-240", size: 240, scale: 1, idiom: "universal"),
        IconSize(name: "background-360", size: 360, scale: 1, idiom: "universal"),
        IconSize(name: "shadow-120", size: 120, scale: 1, idiom: "universal"),
        IconSize(name: "shadow-180", size: 180, scale: 1, idiom: "universal"),
        IconSize(name: "shadow-240", size: 240, scale: 1, idiom: "universal"),
        IconSize(name: "shadow-360", size: 360, scale: 1, idiom: "universal"),
    ]
}

struct ExportConfiguration {
    let format: ExportFormat
    let includeAllPlatforms: Bool
    let liquidGlassEnabled: Bool
    let roundedCorners: Bool
    let cornerRadius: CGFloat

    init(format: ExportFormat = .liquidGlass,
         includeAllPlatforms: Bool = true,
         liquidGlassEnabled: Bool = true,
         roundedCorners: Bool = true,
         cornerRadius: CGFloat = 0.2237) {
        self.format = format
        self.includeAllPlatforms = includeAllPlatforms
        self.liquidGlassEnabled = liquidGlassEnabled
        self.roundedCorners = roundedCorners
        self.cornerRadius = cornerRadius
    }
}
