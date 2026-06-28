#if canImport(ActivityKit)
import ActivityKit
import Foundation

// MARK: - PetLiveActivityAttributes
// Shared ActivityAttributes model used by both the iOS app target and
// the PawPlanWidget extension target.
//
// Static: data that doesn't change for the lifetime of the activity.
// ContentState: dynamic data that gets updated via ActivityKit.

public struct PetLiveActivityAttributes: ActivityAttributes {

    // MARK: - Static Attributes (set once at start)

    /// The unique ID of the calendar event being shown
    public let eventId: UUID
    /// The title of the calendar event
    public let eventTitle: String
    /// SFSymbol name from EventCategory (e.g. "calendar", "heart.fill")
    public let eventCategorySymbol: String
    /// Deep link URL string for navigating to event detail
    public let deepLinkURL: String

    public init(
        eventId: UUID,
        eventTitle: String,
        eventCategorySymbol: String,
        deepLinkURL: String
    ) {
        self.eventId = eventId
        self.eventTitle = eventTitle
        self.eventCategorySymbol = eventCategorySymbol
        self.deepLinkURL = deepLinkURL
    }

    // MARK: - ContentState (dynamic, can be updated)

    public struct ContentState: Codable, Hashable {
        /// PetSpecies.rawValue — "cat" | "dog" | "bunny"
        public let petSpecies: String
        /// PetMood.rawValue
        public let petMood: String
        /// Display name of the pet
        public let petName: String
        /// Selected accessory key — "crown" | "sunglasses" | etc.
        public let selectedAccessory: String?
        /// When the event starts
        public let eventStartDate: Date
        /// When the event ends
        public let eventEndDate: Date
        /// EventStatus.rawValue — "upcoming" | "completed" | etc.
        public let eventStatus: String
        /// Contextual dialogue text shown in the activity
        public let dialogueText: String

        public init(
            petSpecies: String,
            petMood: String,
            petName: String,
            selectedAccessory: String?,
            eventStartDate: Date,
            eventEndDate: Date,
            eventStatus: String,
            dialogueText: String
        ) {
            self.petSpecies = petSpecies
            self.petMood = petMood
            self.petName = petName
            self.selectedAccessory = selectedAccessory
            self.eventStartDate = eventStartDate
            self.eventEndDate = eventEndDate
            self.eventStatus = eventStatus
            self.dialogueText = dialogueText
        }

        // MARK: - Convenience Helpers

        public var petEmoji: String {
            switch petSpecies {
            case "dog":   return "🐶"
            case "bunny": return "🐰"
            default:      return "🐱"
            }
        }

        public var accessoryEmoji: String? {
            switch selectedAccessory {
            case "crown":       return "👑"
            case "sunglasses":  return "🕶️"
            case "headphones":  return "🎧"
            case "tophat":      return "🎩"
            case "ribbon":      return "🎀"
            default:            return nil
            }
        }

        public var isEventOngoing: Bool {
            let now = Date()
            return now >= eventStartDate && now <= eventEndDate
        }

        public var isEventCompleted: Bool {
            eventStatus == "completed"
        }
    }
}
#endif

