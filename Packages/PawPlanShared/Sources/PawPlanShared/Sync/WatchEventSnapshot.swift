import Foundation

public struct WatchEventSnapshot: Codable, Identifiable, Equatable {
    public var id: UUID { eventID }
    public let eventID: UUID
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let category: EventCategory
    public let priority: EventPriority
    public let status: EventStatus
    public let showQuickActions: Bool
    public let isCurrentlyRelevant: Bool
    
    public init(
        eventID: UUID,
        title: String,
        startDate: Date,
        endDate: Date,
        category: EventCategory,
        priority: EventPriority,
        status: EventStatus,
        showQuickActions: Bool,
        isCurrentlyRelevant: Bool
    ) {
        self.eventID = eventID
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.priority = priority
        self.status = status
        self.showQuickActions = showQuickActions
        self.isCurrentlyRelevant = isCurrentlyRelevant
    }
}
