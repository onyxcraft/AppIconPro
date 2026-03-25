import SwiftUI
import AppKit

struct MetalPreviewView: View {
    let image: NSImage?
    let size: CGSize
    let cornerRadius: CGFloat

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: size.width * cornerRadius))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            } else {
                RoundedRectangle(cornerRadius: size.width * cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: size.width, height: size.height)
                    .overlay(
                        Text("No Preview")
                            .foregroundColor(.secondary)
                    )
            }
        }
    }
}
