import SwiftUI

struct IconAdjustmentsView: View {
    @ObservedObject var viewModel: IconEditorViewModel
    @State private var badgeText: String = ""
    @State private var badgeColor: Color = .red

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Adjustments")
                .font(.headline)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Brightness")
                    Spacer()
                    Text(String(format: "%.2f", viewModel.project.brightness))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { viewModel.project.brightness },
                    set: {
                        viewModel.updateAdjustments(
                            brightness: $0,
                            contrast: viewModel.project.contrast,
                            saturation: viewModel.project.saturation
                        )
                    }
                ), in: -1...1)

                HStack {
                    Text("Contrast")
                    Spacer()
                    Text(String(format: "%.2f", viewModel.project.contrast))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { viewModel.project.contrast },
                    set: {
                        viewModel.updateAdjustments(
                            brightness: viewModel.project.brightness,
                            contrast: $0,
                            saturation: viewModel.project.saturation
                        )
                    }
                ), in: -1...1)

                HStack {
                    Text("Saturation")
                    Spacer()
                    Text(String(format: "%.2f", viewModel.project.saturation))
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { viewModel.project.saturation },
                    set: {
                        viewModel.updateAdjustments(
                            brightness: viewModel.project.brightness,
                            contrast: viewModel.project.contrast,
                            saturation: $0
                        )
                    }
                ), in: -1...1)
            }

            Divider()

            Text("Badge")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                TextField("Badge Text", text: $badgeText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: badgeText) { _, newValue in
                        viewModel.updateBadge(
                            text: newValue.isEmpty ? nil : newValue,
                            color: NSColor(badgeColor)
                        )
                    }

                ColorPicker("Badge Color", selection: $badgeColor)
                    .onChange(of: badgeColor) { _, newValue in
                        viewModel.updateBadge(
                            text: badgeText.isEmpty ? nil : badgeText,
                            color: NSColor(newValue)
                        )
                    }
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 250, maxWidth: 300)
    }
}
