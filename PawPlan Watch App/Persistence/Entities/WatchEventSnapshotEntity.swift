import Foundation
import SwiftData
import Combine

@Model
public final class WatchEventSnapshotEntity {
    @Attribute(.unique) public var eventID: UUID
    public var title: String
    public var startDate: Date
    public var endDate: Date
    public var categoryRawValue: String
    public var priorityRawValue: String
    public var statusRawValue: String
    public var showQuickActions: Bool
    public var isCurrentlyRelevant: Bool
    
    public init(
        eventID: UUID,
        title: String,
        startDate: Date,
        endDate: Date,
        categoryRawValue: String,
        priorityRawValue: String,
        statusRawValue: String,
        showQuickActions: Bool = true,
        isCurrentlyRelevant: Bool = true
    ) {
        self.eventID = eventID
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.categoryRawValue = categoryRawValue
        self.priorityRawValue = priorityRawValue
        self.statusRawValue = statusRawValue
        self.showQuickActions = showQuickActions
        self.isCurrentlyRelevant = isCurrentlyRelevant
    }
}
