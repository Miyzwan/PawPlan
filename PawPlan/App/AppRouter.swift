import SwiftUI
import Combine

public final class AppRouter: ObservableObject {
    @Published public var activeTab: AppTab = .dashboard
    
    public enum AppTab: Int, CaseIterable {
        case dashboard
        case calendar
        case settings
    }
    
    public init() {}
}
