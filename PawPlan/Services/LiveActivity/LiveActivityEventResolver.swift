import Foundation
import PawPlanShared

// MARK: - LiveActivityEventResolver
// Encapsulates the rules for when a Live Activity should be shown and
// how to build its ContentState from a CalendarEvent + PetProfile.

public final class LiveActivityEventResolver {

    // MARK: - Constants

    private enum Config {
        /// Show activity if event starts within this many seconds
        static let leadTimeSeconds: TimeInterval = 3 * 3600  // 3 hours
    }

    public init() {}

    // MARK: - Resolution

    /// Determines if a Live Activity should be offered for an event.
    public func shouldShowLiveActivity(for event: CalendarEvent) -> Bool {
        guard event.showInDynamicIsland else { return false }
        guard event.status == .upcoming || event.status == .inProgress else { return false }

        let now = Date()
        let timeUntilStart = event.startDate.timeIntervalSince(now)
        let timeUntilEnd = event.endDate.timeIntervalSince(now)

        // Already finished
        if timeUntilEnd < 0 { return false }

        // Upcoming but within lead time, or currently ongoing
        return timeUntilStart <= Config.leadTimeSeconds
    }

    /// Finds the best event to show a Live Activity for from a list of events.
    /// Priority: currently active > soonest upcoming within lead time.
    public func resolveEvent(from events: [CalendarEvent]) -> CalendarEvent? {
        let now = Date()

        // 1. Currently active event
        if let active = events.first(where: { $0.startDate <= now && $0.endDate >= now && $0.status == .upcoming }) {
            return active
        }

        // 2. Soonest upcoming within lead time
        return events
            .filter { shouldShowLiveActivity(for: $0) }
            .min(by: { $0.startDate < $1.startDate })
    }

    // MARK: - ContentState Builder

    /// Builds the dynamic ContentState from an event and pet profile.
    public func buildContentState(
        event: CalendarEvent,
        pet: PetProfile
    ) -> PetLiveActivityAttributes.ContentState {
        PetLiveActivityAttributes.ContentState(
            petSpecies: pet.species.rawValue,
            petMood: pet.currentMood.rawValue,
            petName: pet.name,
            selectedAccessory: pet.selectedAccessory,
            eventStartDate: event.startDate,
            eventEndDate: event.endDate,
            eventStatus: event.status.rawValue,
            dialogueText: dialogueForContext(event: event, pet: pet)
        )
    }

    /// Builds the static attributes for a new Live Activity.
    public func buildAttributes(for event: CalendarEvent) -> PetLiveActivityAttributes {
        PetLiveActivityAttributes(
            eventId: event.id,
            eventTitle: event.title,
            eventCategorySymbol: event.category.sfSymbol,
            deepLinkURL: "pawplan://event/\(event.id.uuidString)"
        )
    }

    // MARK: - Dialogue

    public func dialogueForContext(event: CalendarEvent, pet: PetProfile) -> String {
        let now = Date()
        let timeUntil = event.startDate.timeIntervalSince(now)

        if event.status == .completed {
            return "Yeay! \"\(event.title)\" selesai! 🎉"
        } else if event.startDate <= now && event.endDate >= now {
            return "\(pet.name) fokus menemanimu! 🧠"
        } else if timeUntil <= 15 * 60 {
            return "Waspada! Segera mulai! ⚠️"
        } else if timeUntil <= 60 * 60 {
            return "Ayo siap-siap! Sebentar lagi! 🐾"
        } else {
            return "\(pet.name) akan mengingatkanmu! 📌"
        }
    }
}
