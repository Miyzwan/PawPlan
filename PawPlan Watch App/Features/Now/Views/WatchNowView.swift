import SwiftUI
import PawPlanShared

public struct WatchNowView: View {
    @StateObject private var viewModel: WatchNowViewModel
    
    public init(viewModel: WatchNowViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .empty:
                VStack {
                    Text("🐾")
                        .font(.title)
                    Text("Agenda Kosong")
                        .font(.headline)
                }
            case .loaded(let snapshot):
                VStack(spacing: 8) {
                    Text(snapshot.pet.petName)
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("🐱")
                        .font(.system(size: 40))
                    
                    if let active = snapshot.activeEvent {
                        Text(active.title)
                            .font(.body)
                            .lineLimit(1)
                    } else {
                        Text("Tidak ada agenda aktif")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            case .error(let error):
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
        .task {
            viewModel.loadSnapshot()
        }
    }
}
