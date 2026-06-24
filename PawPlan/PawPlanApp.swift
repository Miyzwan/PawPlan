import SwiftUI
import SwiftData
import PawPlanShared

@main
struct PawPlanApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var settings = AppSettings()
    private let container: AppContainer
    
    init() {
        // Initialize dependency container
        let modelContainer = SwiftDataModelContainer.create()
        self.container = AppContainer(modelContainer: modelContainer)
        container.registerNotificationDelegate()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(
                viewModel: container.makeRootViewModel(router: router),
                container: container,
                settings: settings
            )
            .modelContainer(container.modelContainer)
        }
    }
}
