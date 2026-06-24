import SwiftUI

public struct WatchTodayView: View {
    @StateObject private var viewModel: WatchTodayViewModel
    
    public init(viewModel: WatchTodayViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text("Agenda Hari Ini")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Text("Belum ada agenda hari ini.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
