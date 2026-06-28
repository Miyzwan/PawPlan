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
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Expected URL: pawplan://event/<UUID>
        guard url.scheme == "pawplan",
              url.host == "event" else { return }
        let eventIdString = url.lastPathComponent
        guard let id = UUID(uuidString: eventIdString) else { return }
        router.navigateToEvent(id: id)
    }
}
