import Foundation
import Combine
import SwiftUI


@MainActor
public final class RootViewModel: ObservableObject {
    public let router: AppRouter
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var activeTab: AppRouter.AppTab {
        get { router.activeTab }
        set { router.activeTab = newValue }
    }
}
