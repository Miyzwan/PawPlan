import Foundation

public enum RecurrenceRule: Codable, Equatable {
    case none
    case daily
    case weekly(selectedWeekdays: [Int])
    case monthly(dayOfMonth: Int)
    case custom(interval: Int, frequency: String, endDate: Date?)
}
