import SwiftUI
import Combine

// MARK: - AppRouter
// Manages the active tab and deep link navigation state.

public final class AppRouter: ObservableObject {
    @Published public var activeTab: AppTab = .dashboard
    @Published public var deepLinkedEventId: UUID? = nil

    public enum AppTab: Int, CaseIterable {
        case dashboard
        case calendar
        case settings
    }

    public init() {}

    // MARK: - Deep Link Handling

    /// Called when a Live Activity deep link is received.
    /// Navigates to the calendar tab and signals which event to open.
    public func navigateToEvent(id: UUID) {
        deepLinkedEventId = id
        activeTab = .calendar
    }

    /// Clears the deep link state after the navigation has been handled.
    public func clearDeepLink() {
        deepLinkedEventId = nil
    }
}
