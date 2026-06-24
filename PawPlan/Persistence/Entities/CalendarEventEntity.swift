import Foundation
import SwiftData
import PawPlanShared
import Combine

// MARK: - CalendarEventEntity
// SwiftData persistence model for CalendarEvent domain model.
// Complex associated-value enums (ReminderOffset, RecurrenceRule) are stored
// as JSON-encoded Data to maintain SwiftData compatibility.

@Model
public final class CalendarEventEntity {

    // MARK: - Stored Properties

    @Attribute(.unique) public var id: UUID
    public var title: String
    public var notes: String?
    public var startDate: Date
    public var endDate: Date
    public var timeZoneIdentifier: String
    public var categoryRawValue: String
    public var priorityRawValue: String
    public var statusRawValue: String
    public var petReactionPresetRawValue: String
    public var sourceRawValue: String
    public var showInDynamicIsland: Bool
    public var showOnAppleWatch: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var completedAt: Date?
    public var externalCalendarEventIdentifier: String?

    // JSON-encoded [ReminderOffset] — stored as Data because ReminderOffset has associated values
    public var reminderOffsetsData: Data

    // JSON-encoded RecurrenceRule? — nil stored as empty Data
    public var recurrenceRuleData: Data?

    // MARK: - Init

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        startDate: Date,
        endDate: Date,
        timeZoneIdentifier: String = TimeZone.current.identifier,
        categoryRawValue: String = EventCategory.other.rawValue,
        priorityRawValue: String = EventPriority.normal.rawValue,
        statusRawValue: String = EventStatus.upcoming.rawValue,
        petReactionPresetRawValue: String = PetReactionPreset.automatic.rawValue,
        sourceRawValue: String = EventSource.local.rawValue,
        showInDynamicIsland: Bool = true,
        showOnAppleWatch: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil,
        externalCalendarEventIdentifier: String? = nil,
        reminderOffsetsData: Data = Data(),
        recurrenceRuleData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.timeZoneIdentifier = timeZoneIdentifier
        self.categoryRawValue = categoryRawValue
        self.priorityRawValue = priorityRawValue
        self.statusRawValue = statusRawValue
        self.petReactionPresetRawValue = petReactionPresetRawValue
        self.sourceRawValue = sourceRawValue
        self.showInDynamicIsland = showInDynamicIsland
        self.showOnAppleWatch = showOnAppleWatch
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.externalCalendarEventIdentifier = externalCalendarEventIdentifier
        self.reminderOffsetsData = reminderOffsetsData
        self.recurrenceRuleData = recurrenceRuleData
    }
}

// MARK: - Domain Conversion

extension CalendarEventEntity {

    /// Creates an entity from a `CalendarEvent` domain model.
    convenience init(from event: CalendarEvent) {
        let encoder = JSONEncoder()
        let offsetsData = (try? encoder.encode(event.reminderOffsets)) ?? Data()
        let recurrenceData = try? encoder.encode(event.recurrenceRule)

        self.init(
            id: event.id,
            title: event.title,
            notes: event.notes,
            startDate: event.startDate,
            endDate: event.endDate,
            timeZoneIdentifier: event.timeZoneIdentifier,
            categoryRawValue: event.category.rawValue,
            priorityRawValue: event.priority.rawValue,
            statusRawValue: event.status.rawValue,
            petReactionPresetRawValue: event.petReactionPreset.rawValue,
            sourceRawValue: event.source.rawValue,
            showInDynamicIsland: event.showInDynamicIsland,
            showOnAppleWatch: event.showOnAppleWatch,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
            completedAt: event.completedAt,
            externalCalendarEventIdentifier: event.externalCalendarEventIdentifier,
            reminderOffsetsData: offsetsData,
            recurrenceRuleData: recurrenceData
        )
    }

    /// Updates the entity's stored properties from an updated `CalendarEvent` domain model.
    func update(from event: CalendarEvent) {
        let encoder = JSONEncoder()
        title = event.title
        notes = event.notes
        startDate = event.startDate
        endDate = event.endDate
        timeZoneIdentifier = event.timeZoneIdentifier
        categoryRawValue = event.category.rawValue
        priorityRawValue = event.priority.rawValue
        statusRawValue = event.status.rawValue
        petReactionPresetRawValue = event.petReactionPreset.rawValue
        sourceRawValue = event.source.rawValue
        showInDynamicIsland = event.showInDynamicIsland
        showOnAppleWatch = event.showOnAppleWatch
        updatedAt = event.updatedAt
        completedAt = event.completedAt
        externalCalendarEventIdentifier = event.externalCalendarEventIdentifier
        reminderOffsetsData = (try? encoder.encode(event.reminderOffsets)) ?? Data()
        recurrenceRuleData = try? encoder.encode(event.recurrenceRule)
    }

    /// Converts the entity back to a `CalendarEvent` domain model.
    func toDomain() -> CalendarEvent {
        let decoder = JSONDecoder()
        let offsets = (try? decoder.decode([ReminderOffset].self, from: reminderOffsetsData)) ?? []
        let recurrence = recurrenceRuleData.flatMap { try? decoder.decode(RecurrenceRule.self, from: $0) }

        return CalendarEvent(
            id: id,
            title: title,
            notes: notes,
            startDate: startDate,
            endDate: endDate,
            timeZoneIdentifier: timeZoneIdentifier,
            category: EventCategory(rawValue: categoryRawValue) ?? .other,
            priority: EventPriority(rawValue: priorityRawValue) ?? .normal,
            status: EventStatus(rawValue: statusRawValue) ?? .upcoming,
            reminderOffsets: offsets,
            recurrenceRule: recurrence,
            showInDynamicIsland: showInDynamicIsland,
            petReactionPreset: PetReactionPreset(rawValue: petReactionPresetRawValue) ?? .automatic,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            source: EventSource(rawValue: sourceRawValue) ?? .local,
            externalCalendarEventIdentifier: externalCalendarEventIdentifier,
            showOnAppleWatch: showOnAppleWatch
        )
    }
}
