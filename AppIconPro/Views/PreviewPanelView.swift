import SwiftUI

struct PreviewPanelView: View {
    @ObservedObject var viewModel: IconEditorViewModel
    @State private var previewSize: CGFloat = 256

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Preview")
                    .font(.headline)

                Spacer()

                Picker("Mode", selection: $viewModel.previewMode) {
                    Text("Liquid Glass").tag(PreviewMode.liquidGlass)
                    Text("Traditional").tag(PreviewMode.traditional)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }

            Divider()

            ScrollView {
                VStack(spacing: 30) {
                    if let preview = viewModel.generatePreview(size: CGSize(width: previewSize, height: previewSize)) {
                        VStack(spacing: 15) {
                            Text("Icon Preview")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            MetalPreviewView(
                                image: preview,
                                size: CGSize(width: previewSize, height: previewSize),
                                cornerRadius: viewModel.project.cornerRadius
                            )
                        }

                        Divider()

                        VStack(spacing: 20) {
                            Text("Context Previews")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 30) {
                                ContextPreviewView(
                                    title: "Home Screen",
                                    icon: preview,
                                    size: 60,
                                    cornerRadius: viewModel.project.cornerRadius
                                )

                                ContextPreviewView(
                                    title: "Settings",
                                    icon: preview,
                                    size: 44,
                                    cornerRadius: viewModel.project.cornerRadius
                                )

                                ContextPreviewView(
                                    title: "Spotlight",
                                    icon: preview,
                                    size: 40,
                                    cornerRadius: viewModel.project.cornerRadius
                                )
                            }

                            HStack(spacing: 30) {
                                ContextPreviewView(
                                    title: "Notification",
                                    icon: preview,
                                    size: 20,
                                    cornerRadius: viewModel.project.cornerRadius
                                )

                                ContextPreviewView(
                                    title: "App Store",
                                    icon: preview,
                                    size: 80,
                                    cornerRadius: viewModel.project.cornerRadius
                                )

                                Spacer()
                                    .frame(width: 80)
                            }
                        }
                    } else {
                        Text("Import an image to see preview")
                            .foregroundColor(.secondary)
                            .frame(height: 300)
                    }
                }
                .padding()
            }

            HStack {
                Text("Preview Size")
                Spacer()
                Slider(value: $previewSize, in: 128...512)
                    .frame(width: 150)
                Text("\(Int(previewSize))px")
                    .foregroundColor(.secondary)
                    .frame(width: 50)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(minWidth: 350)
    }
}

struct ContextPreviewView: View {
    let title: String
    let icon: NSImage
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            MetalPreviewView(
                image: icon,
                size: CGSize(width: size, height: size),
                cornerRadius: cornerRadius
            )

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
