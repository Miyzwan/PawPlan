import Foundation

public enum ReminderOffset: Codable, Equatable {
    case atTime
    case minutesBefore(Int)
    case hoursBefore(Int)
    case daysBefore(Int)
    case custom(DateComponents)
    
    public var timeIntervalBefore: TimeInterval {
        switch self {
        case .atTime:
            return 0
        case .minutesBefore(let mins):
            return TimeInterval(mins * 60)
        case .hoursBefore(let hours):
            return TimeInterval(hours * 3600)
        case .daysBefore(let days):
            return TimeInterval(days * 86400)
        case .custom(let components):
            // Fallback approximation or use Calendar calculation
            let calendar = Calendar.current
            let now = Date()
            if let date = calendar.date(byAdding: components, to: now) {
                return now.timeIntervalSince(date)
            }
            return 0
        }
    }
}
