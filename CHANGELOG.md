# Changelog

All notable changes to AppIcon Pro will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-XX

### Added
- Initial release of AppIcon Pro
- Drag & drop image import functionality
- Automatic foreground/background layer separation using Vision framework
- Manual layer editing with position, scale, and shadow controls
- Liquid Glass preview with Metal-accelerated rendering
- Export to Liquid Glass multi-layer .icon format
- Export to traditional .xcassets format with all standard sizes
- Batch processing for multiple icons
- Template library with 20+ built-in background styles:
  - Solid colors (Black, White)
  - 12 gradient styles (Blue Ocean, Sunset, Purple Dream, etc.)
  - 4 pattern styles (Dots, Grid, Waves, Hexagon)
  - 4 effect styles (Light Glass, Dark Glass, Brushed Metal, Chrome)
- Icon editor with color adjustments (brightness, contrast, saturation)
- Rounded corners preview with adjustable radius
- Badge/text overlay support
- Real-time preview in multiple iOS contexts (Home Screen, Settings, App Store, Notification, Spotlight)
- Dark mode support
- Native macOS 14+ SwiftUI interface
- MVVM architecture for clean code organization
- Settings panel for default preferences
- Keyboard shortcuts for common actions
- App sandbox security with proper entitlements

### Technical Details
- Built with Swift 5.0 and SwiftUI
- Uses Vision framework for AI-powered image segmentation
- Core Image for advanced image processing
- Metal for GPU-accelerated preview rendering
- Supports all iOS, macOS, and watchOS icon sizes
- Exports to sizes: 16x16, 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024
- Liquid Glass sizes: 120x120, 180x180, 240x240, 360x360

### Bundle Information
- Bundle ID: com.lopodragon.appiconpro
- Category: Developer Tools
- Minimum macOS version: 14.0
- Price: $9.99 USD (one-time purchase)

## [Unreleased]

### Planned
- Cloud sync for projects
- Custom template creation and saving
- Animation preview for Liquid Glass effects
- More export formats (PDF, SVG)
- Automated testing suite
- CI/CD pipeline for releases
- Performance optimizations
- Additional template styles
