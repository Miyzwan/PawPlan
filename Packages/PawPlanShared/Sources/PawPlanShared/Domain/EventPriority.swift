import Foundation

public enum EventPriority: String, Codable, CaseIterable, Comparable {
    case low
    case normal
    case high
    case urgent
    
    private var severity: Int {
        switch self {
        case .low: return 0
        case .normal: return 1
        case .high: return 2
        case .urgent: return 3
        }
    }
    
    public static func < (lhs: EventPriority, rhs: EventPriority) -> Bool {
        return lhs.severity < rhs.severity
    }
}
