import Foundation

public final class DateTimeFormatterService {
    public static let shared = DateTimeFormatterService()
    
    private let locale = Locale(identifier: "id_ID")
    
    public init() {}
    
    /// Formats a date to "MMMM yyyy" (e.g. "Juni 2026")
    public func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    /// Formats a date to "EEEE, d MMMM yyyy" (e.g. "Kamis, 25 Juni 2026")
    public func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    /// Formats a date to "HH:mm" (e.g. "14:30")
    public func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    /// Formats weekday index (1-7, where 1 is Sunday) to short weekday name (e.g. "Min", "Sen", etc.)
    public func shortWeekdayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        let symbols = formatter.shortWeekdaySymbols ?? ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
        // Calendar weekday symbols are 0-indexed, but weekday is 1-indexed (1 = Sunday)
        let index = (weekday - 1) % 7
        return symbols[index]
    }
    
    /// Formats time range (e.g. "10:00 - 11:30")
    public func formatTimeRange(start: Date, end: Date) -> String {
        return "\(formatTime(start)) - \(formatTime(end))"
    }
}
