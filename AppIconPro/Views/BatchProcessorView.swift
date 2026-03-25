import SwiftUI

struct BatchProcessorView: View {
    @StateObject private var viewModel = BatchProcessorViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var showTemplateLibrary = false
    @State private var selectedTemplate: Template?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Batch Processor")
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
            .padding()

            Divider()

            if viewModel.projects.isEmpty {
                VStack(spacing: 20) {
                    DropZoneView { image in
                        selectMultipleImages()
                    }
                    .padding()

                    Button("Select Multiple Images") {
                        selectMultipleImages()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 20) {
                    HStack {
                        Text("\(viewModel.projects.count) images loaded")
                            .foregroundColor(.secondary)

                        Spacer()

                        Button("Apply Template to All") {
                            showTemplateLibrary = true
                        }

                        Button("Clear All") {
                            viewModel.clearAll()
                        }
                    }
                    .padding(.horizontal)

                    if viewModel.isProcessing {
                        VStack(spacing: 10) {
                            ProgressView(value: viewModel.currentProgress)
                                .progressViewStyle(.linear)

                            Text("Processing: \(viewModel.completedCount) of \(viewModel.projects.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 15)
                        ], spacing: 15) {
                            ForEach(Array(viewModel.projects.enumerated()), id: \.element.id) { index, project in
                                BatchProjectCell(project: project) {
                                    viewModel.removeProject(at: index)
                                }
                            }
                        }
                        .padding()
                    }

                    Divider()

                    HStack {
                        Spacer()

                        Button("Cancel") {
                            dismiss()
                        }

                        Button("Export All") {
                            exportAll()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isProcessing)
                    }
                    .padding()
                }
            }
        }
        .frame(width: 800, height: 600)
        .sheet(isPresented: $showTemplateLibrary) {
            TemplateSelectionSheet(
                selectedTemplate: $selectedTemplate,
                onSelect: { template in
                    viewModel.applyTemplateToAll(template)
                    showTemplateLibrary = false
                }
            )
        }
    }

    private func selectMultipleImages() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .bmp, .heic]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false

        if panel.runModal() == .OK {
            let images = panel.urls.compactMap { NSImage(contentsOf: $0) }
            Task {
                await viewModel.importImages(images)
            }
        }
    }

    private func exportAll() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true

        if panel.runModal() == .OK, let url = panel.url {
            let configuration = ExportConfiguration()

            Task {
                try? await viewModel.exportAll(to: url, configuration: configuration)
            }
        }
    }
}

struct BatchProjectCell: View {
    let project: IconProject
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let preview = project.foregroundLayer.nsImage() {
                    Image(nsImage: preview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                }

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(8)
            }

            Text(project.name)
                .font(.caption)
                .lineLimit(1)
        }
    }
}

struct TemplateSelectionSheet: View {
    @Binding var selectedTemplate: Template?
    let onSelect: (Template) -> Void
    @Environment(\.dismiss) var dismiss

    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 15)
    ]

    var body: some View {
        VStack {
            HStack {
                Text("Select Template")
                    .font(.title2)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(Template.builtInTemplates) { template in
                        Button(action: {
                            selectedTemplate = template
                            onSelect(template)
                        }) {
                            VStack(spacing: 8) {
                                if let preview = template.generateBackground(size: NSSize(width: 100, height: 100)) {
                                    Image(nsImage: preview)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }

                                Text(template.name)
                                    .font(.caption)
                                    .lineLimit(2)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .frame(width: 600, height: 500)
    }
}
