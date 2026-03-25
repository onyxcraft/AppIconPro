import SwiftUI

struct ExportSheetView: View {
    @ObservedObject var viewModel: IconEditorViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedFormat: ExportFormat = .liquidGlass
    @State private var includeAllPlatforms = true
    @State private var liquidGlassEnabled = true
    @State private var roundedCorners = true
    @State private var isExporting = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Export Icon")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            VStack(alignment: .leading, spacing: 15) {
                Text("Export Format")
                    .font(.headline)

                Picker("Format", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.radioGroup)

                Divider()

                Text("Options")
                    .font(.headline)

                Toggle("Include all platforms (iOS, macOS, watchOS)", isOn: $includeAllPlatforms)

                Toggle("Enable Liquid Glass effects", isOn: $liquidGlassEnabled)
                    .disabled(selectedFormat == .xcassets)

                Toggle("Rounded corners", isOn: $roundedCorners)

                if roundedCorners {
                    HStack {
                        Text("Corner Radius")
                        Spacer()
                        Text(String(format: "%.3f", viewModel.project.cornerRadius))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { viewModel.project.cornerRadius },
                        set: { viewModel.project.cornerRadius = $0 }
                    ), in: 0...0.5)
                }
            }

            Divider()

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Export") {
                    exportIcon()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isExporting)
            }
        }
        .padding()
        .frame(width: 500)
        .alert("Export Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func exportIcon() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = []
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = viewModel.project.name

        if panel.runModal() == .OK, let url = panel.url {
            isExporting = true

            let configuration = ExportConfiguration(
                format: selectedFormat,
                includeAllPlatforms: includeAllPlatforms,
                liquidGlassEnabled: liquidGlassEnabled,
                roundedCorners: roundedCorners,
                cornerRadius: viewModel.project.cornerRadius
            )

            Task {
                do {
                    try await viewModel.exportProject(to: url, configuration: configuration)
                    await MainActor.run {
                        isExporting = false
                        dismiss()
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        showError = true
                        isExporting = false
                    }
                }
            }
        }
    }
}
