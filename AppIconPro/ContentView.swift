import SwiftUI

struct ContentView: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        MainWindowView()
            .frame(minWidth: 900, minHeight: 600)
    }
}

#Preview {
    ContentView()
}
