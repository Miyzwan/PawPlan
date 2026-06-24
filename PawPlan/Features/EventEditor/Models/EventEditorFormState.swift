import Foundation
import PawPlanShared

public struct EventEditorFormState: Equatable {
    public var title: String
    public var notes: String
    public var startDate: Date
    public var endDate: Date
    public var timeZoneIdentifier: String
    public var category: EventCategory
    public var priority: EventPriority
    public var reminderOffsets: [ReminderOffset]
    public var recurrenceRule: RecurrenceRule?
    public var showInDynamicIsland: Bool
    public var petReactionPreset: PetReactionPreset
    public var showOnAppleWatch: Bool
    
    public init(
        title: String = "",
        notes: String = "",
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(3600), // default 1 hour later
        timeZoneIdentifier: String = TimeZone.current.identifier,
        category: EventCategory = .other,
        priority: EventPriority = .normal,
        reminderOffsets: [ReminderOffset] = [],
        recurrenceRule: RecurrenceRule? = nil,
        showInDynamicIsland: Bool = true,
        petReactionPreset: PetReactionPreset = .automatic,
        showOnAppleWatch: Bool = true
    ) {
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.timeZoneIdentifier = timeZoneIdentifier
        self.category = category
        self.priority = priority
        self.reminderOffsets = reminderOffsets
        self.recurrenceRule = recurrenceRule
        self.showInDynamicIsland = showInDynamicIsland
        self.petReactionPreset = petReactionPreset
        self.showOnAppleWatch = showOnAppleWatch
    }
    
    public init(from event: CalendarEvent) {
        self.title = event.title
        self.notes = event.notes ?? ""
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.timeZoneIdentifier = event.timeZoneIdentifier
        self.category = event.category
        self.priority = event.priority
        self.reminderOffsets = event.reminderOffsets
        self.recurrenceRule = event.recurrenceRule
        self.showInDynamicIsland = event.showInDynamicIsland
        self.petReactionPreset = event.petReactionPreset
        self.showOnAppleWatch = event.showOnAppleWatch
    }
    
    public func toCalendarEvent(existingId: UUID? = nil) -> CalendarEvent {
        return CalendarEvent(
            id: existingId ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
            startDate: startDate,
            endDate: endDate,
            timeZoneIdentifier: timeZoneIdentifier,
            category: category,
            priority: priority,
            reminderOffsets: reminderOffsets,
            recurrenceRule: recurrenceRule,
            showInDynamicIsland: showInDynamicIsland,
            petReactionPreset: petReactionPreset,
            showOnAppleWatch: showOnAppleWatch
        )
    }
}
