import SwiftUI

struct LayerControlsView: View {
    @ObservedObject var viewModel: IconEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Layer Controls")
                .font(.headline)

            Divider()

            Group {
                Text("Foreground")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Scale")
                        Spacer()
                        Text(String(format: "%.2f", viewModel.project.foregroundLayer.scale))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { viewModel.project.foregroundLayer.scale },
                        set: { viewModel.updateForegroundScale($0) }
                    ), in: 0.5...2.0)

                    HStack {
                        Text("Offset X")
                        Spacer()
                        Text(String(format: "%.0f", viewModel.project.foregroundLayer.offsetX))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { viewModel.project.foregroundLayer.offsetX },
                        set: { viewModel.updateForegroundOffset(x: $0, y: viewModel.project.foregroundLayer.offsetY) }
                    ), in: -100...100)

                    HStack {
                        Text("Offset Y")
                        Spacer()
                        Text(String(format: "%.0f", viewModel.project.foregroundLayer.offsetY))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { viewModel.project.foregroundLayer.offsetY },
                        set: { viewModel.updateForegroundOffset(x: viewModel.project.foregroundLayer.offsetX, y: $0) }
                    ), in: -100...100)
                }
            }

            Divider()

            Group {
                Text("Background")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Blur Radius")
                        Spacer()
                        Text(String(format: "%.0f", viewModel.project.backgroundLayer.blurRadius))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { viewModel.project.backgroundLayer.blurRadius },
                        set: { viewModel.updateBackgroundBlur($0) }
                    ), in: 0...50)
                }
            }

            Divider()

            Group {
                Text("Shadow")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Radius")
                        Spacer()
                        Text(String(format: "%.0f", viewModel.project.shadowLayer.shadowRadius))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { viewModel.project.shadowLayer.shadowRadius },
                        set: {
                            viewModel.updateShadow(
                                radius: $0,
                                opacity: viewModel.project.shadowLayer.shadowOpacity,
                                offsetX: viewModel.project.shadowLayer.offsetX,
                                offsetY: viewModel.project.shadowLayer.offsetY
                            )
                        }
                    ), in: 0...30)

                    HStack {
                        Text("Opacity")
                        Spacer()
                        Text(String(format: "%.2f", viewModel.project.shadowLayer.shadowOpacity))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { viewModel.project.shadowLayer.shadowOpacity },
                        set: {
                            viewModel.updateShadow(
                                radius: viewModel.project.shadowLayer.shadowRadius,
                                opacity: $0,
                                offsetX: viewModel.project.shadowLayer.offsetX,
                                offsetY: viewModel.project.shadowLayer.offsetY
                            )
                        }
                    ), in: 0...1)
                }
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 250, maxWidth: 300)
    }
}
