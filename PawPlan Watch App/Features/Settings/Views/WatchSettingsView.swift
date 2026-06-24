import SwiftUI

public struct WatchSettingsView: View {
    @StateObject private var viewModel: WatchSettingsViewModel
    
    public init(viewModel: WatchSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        Form {
            Section(header: Text("Sinkronisasi")) {
                HStack {
                    Text("Status")
                    Spacer()
                    Text("Terhubung")
                        .foregroundColor(.green)
                }
            }
        }
    }
}
