import SwiftUI
import SwiftData
import PawPlanShared

@main
struct PawPlan_Watch_AppApp: App {
    private let container: WatchAppContainer
    
    init() {
        let modelContainer = WatchSwiftDataModelContainer.create()
        self.container = WatchAppContainer(modelContainer: modelContainer)
    }
    
    var body: some Scene {
        WindowGroup {
            WatchRootView(
                viewModel: container.makeWatchRootViewModel(),
                container: container
            )
            .modelContainer(container.modelContainer)
        }
    }
}
