import SwiftUI

struct TemplateLibraryView: View {
    @ObservedObject var viewModel: IconEditorViewModel
    @Environment(\.dismiss) var dismiss

    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 15)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Template Library")
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

            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(Template.builtInTemplates) { template in
                        TemplateCell(
                            template: template,
                            isSelected: viewModel.selectedTemplate?.id == template.id
                        ) {
                            viewModel.applyTemplate(template)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct TemplateCell: View {
    let template: Template
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let preview = template.generateBackground(size: NSSize(width: 100, height: 100)) {
                    Image(nsImage: preview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                }

                Text(template.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 30)
            }
        }
        .buttonStyle(.plain)
    }
}
