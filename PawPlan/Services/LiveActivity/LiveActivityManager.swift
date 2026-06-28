import ActivityKit
import Foundation
import PawPlanShared

// MARK: - LiveActivityManager
// Concrete implementation of LiveActivityManagerProtocol using ActivityKit.
// Ensures only one Live Activity is active at a time.
// Gracefully degrades when ActivityKit is unavailable (older devices/simulators).

public final class LiveActivityManager: LiveActivityManagerProtocol {

    // MARK: - Singleton access (optional convenience)
    public static let shared = LiveActivityManager()

    // MARK: - State

    /// Tracks the currently active Live Activity
    private var currentActivity: Activity<PetLiveActivityAttributes>?

    // MARK: - Init

    public init() {}

    // MARK: - LiveActivityManagerProtocol

    public var isAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    public func startActivity(
        eventId: UUID,
        eventTitle: String,
        eventCategorySymbol: String,
        deepLinkURL: String,
        contentState: PetLiveActivityAttributes.ContentState
    ) async throws {
        guard isAvailable else {
            return  // Silently skip on unsupported devices
        }

        // End any existing activity first (only one active at a time)
        await endAllActivities()

        let attributes = PetLiveActivityAttributes(
            eventId: eventId,
            eventTitle: eventTitle,
            eventCategorySymbol: eventCategorySymbol,
            deepLinkURL: deepLinkURL
        )

        let content = ActivityContent(
            state: contentState,
            staleDate: Calendar.current.date(byAdding: .hour, value: 4, to: Date()),
            relevanceScore: 100
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivity = activity
        } catch {
            throw error
        }
    }

    public func updateActivity(with contentState: PetLiveActivityAttributes.ContentState) async {
        guard let activity = currentActivity else { return }

        let content = ActivityContent(
            state: contentState,
            staleDate: Calendar.current.date(byAdding: .hour, value: 4, to: Date()),
            relevanceScore: 100
        )

        await activity.update(content)
    }

    public func endActivity(for eventId: UUID) async {
        // Find activity matching this event ID
        for activity in Activity<PetLiveActivityAttributes>.activities {
            if activity.attributes.eventId == eventId {
                let dismissalPolicy = ActivityUIDismissalPolicy.default
                await activity.end(nil, dismissalPolicy: dismissalPolicy)
                if currentActivity?.id == activity.id {
                    currentActivity = nil
                }
            }
        }
    }

    public func endAllActivities() async {
        for activity in Activity<PetLiveActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}

// MARK: - DummyLiveActivityManager
// No-op implementation for test environments or unsupported devices.

public final class DummyLiveActivityManager: LiveActivityManagerProtocol {
    public init() {}
    public var isAvailable: Bool { false }
    public func startActivity(eventId: UUID, eventTitle: String, eventCategorySymbol: String, deepLinkURL: String, contentState: PetLiveActivityAttributes.ContentState) async throws {}
    public func updateActivity(with contentState: PetLiveActivityAttributes.ContentState) async {}
    public func endActivity(for eventId: UUID) async {}
    public func endAllActivities() async {}
}
