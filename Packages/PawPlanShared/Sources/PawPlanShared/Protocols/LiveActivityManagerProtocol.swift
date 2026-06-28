#if canImport(ActivityKit)
import Foundation

// MARK: - LiveActivityManagerProtocol
// Abstraction for managing Live Activity lifecycle.
// Defined in the shared package so it can be mocked in unit tests.

public protocol LiveActivityManagerProtocol: Sendable {
    /// Starts a new Live Activity for the given event and pet state.
    /// Ends any existing activity first to ensure only one is active.
    func startActivity(
        eventId: UUID,
        eventTitle: String,
        eventCategorySymbol: String,
        deepLinkURL: String,
        contentState: PetLiveActivityAttributes.ContentState
    ) async throws

    /// Updates the content state of the currently active Live Activity.
    func updateActivity(with contentState: PetLiveActivityAttributes.ContentState) async

    /// Ends the active Live Activity for a specific event.
    func endActivity(for eventId: UUID) async

    /// Ends all active Live Activities.
    func endAllActivities() async

    /// Returns true if ActivityKit is available and authorized on this device.
    var isAvailable: Bool { get }
}
#endif

