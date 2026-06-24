import Foundation
import Combine

@MainActor
public final class WatchRootViewModel: ObservableObject {
    @Published public var activeTab: WatchTab = .now
    
    public enum WatchTab {
        case now
        case today
        case pet
    }
    
    public init() {}
}
