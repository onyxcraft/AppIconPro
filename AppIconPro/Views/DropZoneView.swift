import SwiftUI
import AppKit

struct DropZoneView: View {
    let onImageDropped: (NSImage) -> Void
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(isDragging ? .accentColor : .secondary)

            Text("Drag & Drop Image Here")
                .font(.title2)
                .foregroundColor(.primary)

            Text("or click to browse")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Select Image") {
                selectImage()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isDragging ? Color.accentColor : Color.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [10])
                )
        )
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isDragging ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .onDrop(of: [.image, .fileURL], isTargeted: $isDragging) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }

        if provider.hasItemConformingToTypeIdentifier("public.image") {
            provider.loadItem(forTypeIdentifier: "public.image", options: nil) { item, error in
                if let url = item as? URL, let image = NSImage(contentsOf: url) {
                    DispatchQueue.main.async {
                        onImageDropped(image)
                    }
                } else if let data = item as? Data, let image = NSImage(data: data) {
                    DispatchQueue.main.async {
                        onImageDropped(image)
                    }
                }
            }
        } else if provider.hasItemConformingToTypeIdentifier("public.file-url") {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                if let url = item as? URL, let image = NSImage(contentsOf: url) {
                    DispatchQueue.main.async {
                        onImageDropped(image)
                    }
                }
            }
        }
    }

    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .bmp, .heic]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url, let image = NSImage(contentsOf: url) {
            onImageDropped(image)
        }
    }
}
