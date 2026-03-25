import SwiftUI

struct MainWindowView: View {
    @StateObject private var viewModel = IconEditorViewModel()
    @State private var showBatchProcessor = false

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                List {
                    Section("Tools") {
                        NavigationLink(destination: IconEditorView(viewModel: viewModel)) {
                            Label("Icon Editor", systemImage: "paintbrush")
                        }

                        Button(action: { showBatchProcessor = true }) {
                            Label("Batch Processor", systemImage: "square.stack.3d.up")
                        }
                        .buttonStyle(.plain)
                    }

                    Section("Export") {
                        Button(action: {}) {
                            Label("Liquid Glass Format", systemImage: "sparkles")
                        }
                        .buttonStyle(.plain)
                        .disabled(true)

                        Button(action: {}) {
                            Label("Traditional Assets", systemImage: "square.grid.3x3")
                        }
                        .buttonStyle(.plain)
                        .disabled(true)
                    }
                }
                .listStyle(.sidebar)

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("AppIcon Pro")
                        .font(.headline)

                    Text("v1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("iOS 26 Liquid Glass Ready")
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                }
                .padding()
            }
            .frame(minWidth: 220)
        } detail: {
            IconEditorView(viewModel: viewModel)
        }
        .sheet(isPresented: $showBatchProcessor) {
            BatchProcessorView()
        }
    }
}
