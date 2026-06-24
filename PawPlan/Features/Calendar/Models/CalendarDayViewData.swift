import Foundation
import PawPlanShared

public struct CalendarDayViewData: Identifiable, Equatable {
    public var id: Date { date }
    
    public let date: Date
    public let dayNumber: String
    public let isCurrentMonth: Bool
    public let isToday: Bool
    public let isSelected: Bool
    public let events: [CalendarEvent]
    
    public init(
        date: Date,
        dayNumber: String,
        isCurrentMonth: Bool,
        isToday: Bool,
        isSelected: Bool,
        events: [CalendarEvent] = []
    ) {
        self.date = date
        self.dayNumber = dayNumber
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.isSelected = isSelected
        self.events = events
    }
}
