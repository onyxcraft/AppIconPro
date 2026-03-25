# AppIcon Pro

Premium macOS app icon generator with iOS 26 Liquid Glass support.

## Overview

AppIcon Pro is a professional-grade macOS application designed for developers preparing for iOS 26's revolutionary Liquid Glass icon format. This app provides powerful tools for creating stunning app icons with automatic foreground/background separation, advanced editing capabilities, and seamless export to multiple formats.

## Features

### Core Features
- **Drag & Drop Import**: Import any image as a base icon via intuitive drag & drop or file picker
- **AI-Powered Layer Separation**: Automatic foreground/background separation using Apple's Vision framework (VNGenerateForegroundInstanceMaskRequest)
- **Manual Layer Editing**: Fine-tune foreground position, scale, shadow, background blur, and color
- **Liquid Glass Preview**: Real-time simulation of iOS 26's frosted glass depth effect with multi-layer rendering

### Export Capabilities
- **Liquid Glass Format**: Export as multi-layer .icon asset (foreground.png + background.png + shadow.png at all required sizes: 120, 180, 240, 360)
- **Traditional Assets**: Export as .xcassets folder with all standard sizes (16x16 to 1024x1024) for iOS, macOS, watchOS
- **Batch Processing**: Import and process multiple icons simultaneously

### Design Tools
- **Template Library**: 20+ built-in icon background styles including:
  - Solid colors (Black, White)
  - Gradients (Blue Ocean, Sunset, Purple Dream, Green Forest, Fire Orange, Cool Mint, Rose Gold, Neon Pink, Deep Space, Aurora, Golden Hour, Midnight)
  - Patterns (Dots, Grid, Waves, Hexagon)
  - Effects (Light Glass, Dark Glass, Brushed Metal, Chrome)
- **Icon Editor**:
  - Rounded corners preview with adjustable radius
  - Badge/text overlay support
  - Color adjustments (brightness, contrast, saturation)
- **Real-time Preview**: View icons in simulated iOS contexts (Home Screen, Settings, App Store, Notification, Spotlight)

### Additional Features
- Native macOS 14+ SwiftUI interface
- Dark mode support
- MVVM architecture for clean, maintainable code
- Metal-accelerated rendering for smooth previews
- No external API dependencies

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for building from source)

## Installation

### From Source

1. Clone the repository:
```bash
git clone https://github.com/lopodragon/appiconpro.git
cd appiconpro
```

2. Open the project in Xcode:
```bash
open AppIconPro.xcodeproj
```

3. Build and run (⌘R)

### App Store

Coming soon - AppIcon Pro will be available on the Mac App Store for $9.99 USD.

## Usage

### Basic Workflow

1. **Import Image**: Drag and drop an image or click "Select Image" to browse
2. **Auto-Separation**: The app automatically separates foreground and background using AI
3. **Apply Template** (Optional): Choose from 20+ background templates
4. **Adjust Layers**: Fine-tune foreground position, scale, shadow, and background blur
5. **Preview**: View real-time preview with Liquid Glass effects
6. **Export**: Choose format (Liquid Glass, XCAssets, or Both) and export

### Layer Controls

- **Foreground Layer**:
  - Scale: 0.5x - 2.0x
  - Offset X/Y: -100 to +100 pixels
  - Shadow radius and opacity

- **Background Layer**:
  - Blur radius: 0 - 50 pixels
  - Template application
  - Color adjustments

- **Adjustments**:
  - Brightness: -1.0 to +1.0
  - Contrast: -1.0 to +1.0
  - Saturation: -1.0 to +1.0
  - Badge text and color

### Batch Processing

1. Open Batch Processor from the sidebar
2. Select multiple images
3. Apply template to all (optional)
4. Export all icons at once

## Architecture

AppIcon Pro is built with modern Swift and SwiftUI using the MVVM pattern:

```
AppIconPro/
├── Models/              # Data models
│   ├── IconProject.swift
│   ├── Layer.swift
│   ├── Template.swift
│   └── ExportFormat.swift
├── Views/               # SwiftUI views
│   ├── MainWindowView.swift
│   ├── IconEditorView.swift
│   ├── LayerControlsView.swift
│   ├── PreviewPanelView.swift
│   ├── TemplateLibraryView.swift
│   ├── ExportSheetView.swift
│   └── BatchProcessorView.swift
├── ViewModels/          # Business logic
│   ├── IconEditorViewModel.swift
│   └── BatchProcessorViewModel.swift
└── Services/            # Core services
    ├── VisionService.swift       # AI layer separation
    ├── ImageProcessor.swift      # Image manipulation
    ├── ExportService.swift       # Export functionality
    └── MetalRenderer.swift       # Liquid Glass preview
```

## Technologies

- **SwiftUI + AppKit**: Native macOS interface
- **Vision Framework**: AI-powered foreground/background separation
- **Core Image**: Advanced image processing and filters
- **Metal**: GPU-accelerated Liquid Glass preview rendering
- **Combine**: Reactive data flow

## Liquid Glass Format

The iOS 26 Liquid Glass format is a multi-layer icon system that creates a stunning depth effect:

```
MyIcon.icon/
├── foreground-120.png
├── foreground-180.png
├── foreground-240.png
├── foreground-360.png
├── background-120.png
├── background-180.png
├── background-240.png
├── background-360.png
├── shadow-120.png
├── shadow-180.png
├── shadow-240.png
├── shadow-360.png
└── Contents.json
```

Each layer serves a specific purpose:
- **Foreground**: Main icon content with transparency
- **Background**: Blurred or styled background layer
- **Shadow**: Depth shadow for 3D effect

## Bundle Information

- **Bundle ID**: com.lopodragon.appiconpro
- **Category**: Developer Tools
- **Price**: $9.99 USD (one-time purchase)
- **Version**: 1.0.0

## License

MIT License - See LICENSE file for details

## Support

For support, feature requests, or bug reports:
- GitHub Issues: https://github.com/lopodragon/appiconpro/issues
- Email: support@lopodragon.com

## Roadmap

- [ ] Cloud sync for projects
- [ ] Custom template creation
- [ ] Animation preview
- [ ] Automated testing suite
- [ ] CI/CD pipeline

## Credits

Developed by LopoDragon
© 2025 LopoDragon. All rights reserved.

## Acknowledgments

- Apple Vision Framework for AI-powered segmentation
- Swift and SwiftUI community
- iOS 26 Liquid Glass icon format specification
