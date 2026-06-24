import Foundation
import PawPlanShared

public final class SystemCalendarProvider: CalendarProviderProtocol {
    public init() {}
    
    public func currentCalendar() -> Calendar {
        return Calendar.current
    }
}
