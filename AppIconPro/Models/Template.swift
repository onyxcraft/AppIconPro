import Foundation
import AppKit

enum TemplateStyle: String, Codable, CaseIterable {
    case solidBlack = "Solid Black"
    case solidWhite = "Solid White"
    case gradientBlueOcean = "Blue Ocean"
    case gradientSunset = "Sunset"
    case gradientPurpleDream = "Purple Dream"
    case gradientGreenForest = "Green Forest"
    case gradientFireOrange = "Fire Orange"
    case gradientCoolMint = "Cool Mint"
    case gradientRoseGold = "Rose Gold"
    case gradientNeonPink = "Neon Pink"
    case gradientDeepSpace = "Deep Space"
    case gradientAurora = "Aurora"
    case patternDots = "Dots Pattern"
    case patternGrid = "Grid Pattern"
    case patternWaves = "Waves Pattern"
    case patternHexagon = "Hexagon Pattern"
    case glassLight = "Light Glass"
    case glassDark = "Dark Glass"
    case metalBrushed = "Brushed Metal"
    case metalChrome = "Chrome"
    case gradientGoldenHour = "Golden Hour"
    case gradientMidnight = "Midnight"
}

struct Template: Identifiable, Codable {
    let id: UUID
    let name: String
    let style: TemplateStyle
    var backgroundLayer: Layer

    init(id: UUID = UUID(), name: String, style: TemplateStyle) {
        self.id = id
        self.name = name
        self.style = style
        self.backgroundLayer = Layer(type: .background)
    }

    static var builtInTemplates: [Template] {
        TemplateStyle.allCases.map { style in
            Template(name: style.rawValue, style: style)
        }
    }

    func generateBackground(size: CGSize) -> NSImage? {
        let image = NSImage(size: size)
        image.lockFocus()

        guard let context = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return nil
        }

        let rect = CGRect(origin: .zero, size: size)

        switch style {
        case .solidBlack:
            context.setFillColor(NSColor.black.cgColor)
            context.fill(rect)

        case .solidWhite:
            context.setFillColor(NSColor.white.cgColor)
            context.fill(rect)

        case .gradientBlueOcean:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0),
                                NSColor(red: 0.0, green: 0.7, blue: 0.9, alpha: 1.0)])

        case .gradientSunset:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0),
                                NSColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)])

        case .gradientPurpleDream:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0),
                                NSColor(red: 0.8, green: 0.3, blue: 0.9, alpha: 1.0)])

        case .gradientGreenForest:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 0.1, green: 0.5, blue: 0.2, alpha: 1.0),
                                NSColor(red: 0.3, green: 0.7, blue: 0.4, alpha: 1.0)])

        case .gradientFireOrange:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0),
                                NSColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)])

        case .gradientCoolMint:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 0.2, green: 0.8, blue: 0.7, alpha: 1.0),
                                NSColor(red: 0.4, green: 0.9, blue: 0.8, alpha: 1.0)])

        case .gradientRoseGold:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 0.9, green: 0.7, blue: 0.6, alpha: 1.0),
                                NSColor(red: 1.0, green: 0.8, blue: 0.7, alpha: 1.0)])

        case .gradientNeonPink:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 1.0, green: 0.1, blue: 0.5, alpha: 1.0),
                                NSColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0)])

        case .gradientDeepSpace:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 1.0),
                                NSColor(red: 0.1, green: 0.1, blue: 0.4, alpha: 1.0)])

        case .gradientAurora:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 0.0, green: 0.8, blue: 0.6, alpha: 1.0),
                                NSColor(red: 0.5, green: 0.3, blue: 0.9, alpha: 1.0)])

        case .gradientGoldenHour:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0),
                                NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)])

        case .gradientMidnight:
            drawGradient(context: context, rect: rect,
                        colors: [NSColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0),
                                NSColor(red: 0.2, green: 0.2, blue: 0.5, alpha: 1.0)])

        case .patternDots:
            context.setFillColor(NSColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0).cgColor)
            context.fill(rect)
            drawDotPattern(context: context, rect: rect)

        case .patternGrid:
            context.setFillColor(NSColor.white.cgColor)
            context.fill(rect)
            drawGridPattern(context: context, rect: rect)

        case .patternWaves:
            context.setFillColor(NSColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor)
            context.fill(rect)
            drawWavePattern(context: context, rect: rect)

        case .patternHexagon:
            context.setFillColor(NSColor.white.cgColor)
            context.fill(rect)
            drawHexagonPattern(context: context, rect: rect)

        case .glassLight:
            drawGlassEffect(context: context, rect: rect, isDark: false)

        case .glassDark:
            drawGlassEffect(context: context, rect: rect, isDark: true)

        case .metalBrushed:
            drawBrushedMetal(context: context, rect: rect)

        case .metalChrome:
            drawChromeEffect(context: context, rect: rect)
        }

        image.unlockFocus()
        return image
    }

    private func drawGradient(context: CGContext, rect: CGRect, colors: [NSColor]) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let cgColors = colors.map { $0.cgColor } as CFArray
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: nil) else { return }
        context.drawLinearGradient(gradient, start: CGPoint(x: rect.midX, y: rect.minY),
                                  end: CGPoint(x: rect.midX, y: rect.maxY), options: [])
    }

    private func drawDotPattern(context: CGContext, rect: CGRect) {
        context.setFillColor(NSColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 0.3).cgColor)
        let spacing: CGFloat = 20
        for x in stride(from: 0, to: rect.width, by: spacing) {
            for y in stride(from: 0, to: rect.height, by: spacing) {
                context.fillEllipse(in: CGRect(x: x, y: y, width: 6, height: 6))
            }
        }
    }

    private func drawGridPattern(context: CGContext, rect: CGRect) {
        context.setStrokeColor(NSColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0).cgColor)
        context.setLineWidth(1)
        let spacing: CGFloat = 30
        for x in stride(from: 0, to: rect.width, by: spacing) {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, to: rect.height, by: spacing) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
        }
        context.strokePath()
    }

    private func drawWavePattern(context: CGContext, rect: CGRect) {
        context.setStrokeColor(NSColor(red: 0.5, green: 0.6, blue: 0.9, alpha: 0.5).cgColor)
        context.setLineWidth(2)
        let amplitude: CGFloat = 15
        let frequency: CGFloat = 4
        for offset in stride(from: 0, to: rect.height, by: 20) {
            context.beginPath()
            for x in stride(from: 0, to: rect.width, by: 2) {
                let y = offset + amplitude * sin(frequency * x / rect.width * .pi * 2)
                if x == 0 {
                    context.move(to: CGPoint(x: x, y: y))
                } else {
                    context.addLine(to: CGPoint(x: x, y: y))
                }
            }
            context.strokePath()
        }
    }

    private func drawHexagonPattern(context: CGContext, rect: CGRect) {
        context.setStrokeColor(NSColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 0.5).cgColor)
        context.setLineWidth(1)
        let size: CGFloat = 25
        let height = size * sqrt(3)
        for row in stride(from: -size, to: rect.height + size, by: height) {
            for col in stride(from: -size, to: rect.width + size, by: size * 1.5) {
                let offsetX = (row / height).truncatingRemainder(dividingBy: 2) == 0 ? 0 : size * 0.75
                drawHexagon(context: context, center: CGPoint(x: col + offsetX, y: row), size: size)
            }
        }
    }

    private func drawHexagon(context: CGContext, center: CGPoint, size: CGFloat) {
        context.beginPath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let x = center.x + size * cos(angle)
            let y = center.y + size * sin(angle)
            if i == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.closePath()
        context.strokePath()
    }

    private func drawGlassEffect(context: CGContext, rect: CGRect, isDark: Bool) {
        let baseColor = isDark ? NSColor(white: 0.15, alpha: 0.8) : NSColor(white: 0.95, alpha: 0.8)
        context.setFillColor(baseColor.cgColor)
        context.fill(rect)

        let highlightColor = isDark ? NSColor(white: 0.3, alpha: 0.3) : NSColor(white: 1.0, alpha: 0.5)
        context.setFillColor(highlightColor.cgColor)
        context.fill(CGRect(x: 0, y: rect.height * 0.5, width: rect.width, height: rect.height * 0.5))
    }

    private func drawBrushedMetal(context: CGContext, rect: CGRect) {
        context.setFillColor(NSColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0).cgColor)
        context.fill(rect)
        context.setStrokeColor(NSColor(white: 0.6, alpha: 0.3).cgColor)
        context.setLineWidth(0.5)
        for y in stride(from: 0, to: rect.height, by: 1) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
        }
        context.strokePath()
    }

    private func drawChromeEffect(context: CGContext, rect: CGRect) {
        drawGradient(context: context, rect: rect,
                    colors: [NSColor(white: 0.9, alpha: 1.0),
                            NSColor(white: 0.7, alpha: 1.0),
                            NSColor(white: 0.9, alpha: 1.0)])
    }
}
