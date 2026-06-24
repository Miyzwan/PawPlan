import Foundation

// MARK: - DateProviderProtocol
// Abstraction for providing the current date.
// Inject this into ViewModels and services to enable deterministic unit testing.

public protocol DateProviderProtocol {
    /// Returns the current date and time.
    func currentDate() -> Date
}

extension DateProviderProtocol {
    /// Convenience property — equivalent to currentDate().
    public var now: Date { currentDate() }
}

// MARK: - CalendarProviderProtocol
// Abstraction for calendar operations.
// Inject this into ViewModels and services to enable testable date calculations.

public protocol CalendarProviderProtocol {
    /// Returns the user's current calendar.
    func currentCalendar() -> Calendar

    /// Returns true if two dates fall on the same calendar day.
    func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool

    /// Returns the start of the calendar day for the given date.
    func startOfDay(for date: Date) -> Date
}

extension CalendarProviderProtocol {
    public func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        currentCalendar().isDate(date1, inSameDayAs: date2)
    }

    public func startOfDay(for date: Date) -> Date {
        currentCalendar().startOfDay(for: date)
    }
}
