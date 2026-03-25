import SwiftUI

@main
struct AppIconProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Project") {
                    NotificationCenter.default.post(name: .newProject, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandGroup(after: .importExport) {
                Button("Import Image...") {
                    NotificationCenter.default.post(name: .importImage, object: nil)
                }
                .keyboardShortcut("i", modifiers: .command)

                Button("Export Icon...") {
                    NotificationCenter.default.post(name: .exportIcon, object: nil)
                }
                .keyboardShortcut("e", modifiers: .command)

                Divider()

                Button("Batch Processor...") {
                    NotificationCenter.default.post(name: .batchProcessor, object: nil)
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @AppStorage("defaultExportFormat") private var defaultExportFormat = "liquidGlass"
    @AppStorage("autoSeparateLayers") private var autoSeparateLayers = true
    @AppStorage("defaultCornerRadius") private var defaultCornerRadius = 0.2237

    var body: some View {
        TabView {
            Form {
                Section("Export") {
                    Picker("Default Export Format", selection: $defaultExportFormat) {
                        Text("Liquid Glass").tag("liquidGlass")
                        Text("XCAssets").tag("xcassets")
                        Text("Both").tag("both")
                    }

                    Toggle("Auto-separate layers on import", isOn: $autoSeparateLayers)

                    HStack {
                        Text("Default Corner Radius")
                        Spacer()
                        TextField("", value: $defaultCornerRadius, format: .number)
                            .frame(width: 80)
                    }
                }
            }
            .padding()
            .frame(width: 400, height: 200)
            .tabItem {
                Label("General", systemImage: "gearshape")
            }

            Form {
                Section("About") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AppIcon Pro")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Version 1.0.0")
                            .foregroundColor(.secondary)

                        Text("Premium app icon generator with iOS 26 Liquid Glass support")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Divider()

                        Text("© 2025 LopoDragon. All rights reserved.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Bundle ID: com.lopodragon.appiconpro")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .padding()
            .frame(width: 400, height: 300)
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
    }
}

extension Notification.Name {
    static let newProject = Notification.Name("newProject")
    static let importImage = Notification.Name("importImage")
    static let exportIcon = Notification.Name("exportIcon")
    static let batchProcessor = Notification.Name("batchProcessor")
}
