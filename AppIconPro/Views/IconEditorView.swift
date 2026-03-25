import SwiftUI

struct IconEditorView: View {
    @ObservedObject var viewModel: IconEditorViewModel
    @State private var showTemplateLibrary = false
    @State private var showExportSheet = false

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        LayerControlsView(viewModel: viewModel)

                        Divider()

                        IconAdjustmentsView(viewModel: viewModel)
                    }
                }
            }
            .frame(minWidth: 250, maxWidth: 300)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            VStack(spacing: 0) {
                if viewModel.project.foregroundLayer.image == nil {
                    DropZoneView { image in
                        Task {
                            await viewModel.importImage(image)
                        }
                    }
                    .padding()
                } else {
                    PreviewPanelView(viewModel: viewModel)
                }

                if viewModel.isProcessing {
                    ProgressView("Processing image...")
                        .padding()
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: { showTemplateLibrary = true }) {
                    Label("Templates", systemImage: "square.grid.2x2")
                }
                .disabled(viewModel.project.foregroundLayer.image == nil)

                Button(action: { showExportSheet = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.project.foregroundLayer.image == nil)

                Button(action: { viewModel.resetProject() }) {
                    Label("New", systemImage: "doc.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showTemplateLibrary) {
            TemplateLibraryView(viewModel: viewModel)
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheetView(viewModel: viewModel)
        }
    }
}
