import SwiftUI

public struct WatchRootView: View {
    @StateObject private var viewModel: WatchRootViewModel
    private let container: WatchAppContainer
    
    public init(viewModel: WatchRootViewModel, container: WatchAppContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }
    
    public var body: some View {
        TabView(selection: $viewModel.activeTab) {
            WatchNowView(viewModel: container.makeWatchNowViewModel())
                .tag(WatchRootViewModel.WatchTab.now)
            
            WatchTodayView(viewModel: container.makeWatchTodayViewModel())
                .tag(WatchRootViewModel.WatchTab.today)
            
            WatchPetView(viewModel: container.makeWatchPetViewModel())
                .tag(WatchRootViewModel.WatchTab.pet)
        }
        .tabViewStyle(.page)
    }
}
