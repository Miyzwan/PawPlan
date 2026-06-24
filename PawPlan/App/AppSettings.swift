import Foundation
import Combine

public final class AppSettings: ObservableObject {
    @Published public var showFullEventTitle: Bool = true
    @Published public var enableWatchHaptic: Bool = true
    
    public init() {}
}
