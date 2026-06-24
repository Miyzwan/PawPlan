import SwiftUI

public struct WatchPetView: View {
    @StateObject private var viewModel: WatchPetViewModel
    
    public init(viewModel: WatchPetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            Text("Milo")
                .font(.headline)
            Text("🐱")
                .font(.system(size: 50))
            Text("Level 1 • XP 10")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
