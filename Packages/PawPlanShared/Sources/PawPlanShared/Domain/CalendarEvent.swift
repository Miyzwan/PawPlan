import Foundation

public struct CalendarEvent: Codable, Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var startDate: Date
    public var endDate: Date
    public var timeZoneIdentifier: String
    public var category: EventCategory
    public var priority: EventPriority
    public var status: EventStatus
    public var reminderOffsets: [ReminderOffset]
    public var recurrenceRule: RecurrenceRule?
    public var showInDynamicIsland: Bool
    public var petReactionPreset: PetReactionPreset
    public var createdAt: Date
    public var updatedAt: Date
    public var completedAt: Date?
    public var source: EventSource
    public var externalCalendarEventIdentifier: String?
    public var showOnAppleWatch: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        startDate: Date,
        endDate: Date,
        timeZoneIdentifier: String = TimeZone.current.identifier,
        category: EventCategory = .other,
        priority: EventPriority = .normal,
        status: EventStatus = .upcoming,
        reminderOffsets: [ReminderOffset] = [],
        recurrenceRule: RecurrenceRule? = nil,
        showInDynamicIsland: Bool = true,
        petReactionPreset: PetReactionPreset = .automatic,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil,
        source: EventSource = .local,
        externalCalendarEventIdentifier: String? = nil,
        showOnAppleWatch: Bool = true
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.timeZoneIdentifier = timeZoneIdentifier
        self.category = category
        self.priority = priority
        self.status = status
        self.reminderOffsets = reminderOffsets
        self.recurrenceRule = recurrenceRule
        self.showInDynamicIsland = showInDynamicIsland
        self.petReactionPreset = petReactionPreset
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.source = source
        self.externalCalendarEventIdentifier = externalCalendarEventIdentifier
        self.showOnAppleWatch = showOnAppleWatch
    }
}
