import Foundation

public protocol DateProviderProtocol {
    func currentDate() -> Date
}

public protocol CalendarProviderProtocol {
    func currentCalendar() -> Calendar
}
