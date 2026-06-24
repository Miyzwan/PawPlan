import Foundation
import SwiftData
import PawPlanShared
import Combine

@Model
public final class CalendarEventEntity {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var notes: String?
    public var startDate: Date
    public var endDate: Date
    public var categoryRawValue: String
    public var priorityRawValue: String
    public var statusRawValue: String
    public var showInDynamicIsland: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var showOnAppleWatch: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        startDate: Date,
        endDate: Date,
        categoryRawValue: String,
        priorityRawValue: String,
        statusRawValue: String,
        showInDynamicIsland: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        showOnAppleWatch: Bool = true
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.categoryRawValue = categoryRawValue
        self.priorityRawValue = priorityRawValue
        self.statusRawValue = statusRawValue
        self.showInDynamicIsland = showInDynamicIsland
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.showOnAppleWatch = showOnAppleWatch
    }
}
