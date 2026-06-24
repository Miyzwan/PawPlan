import Foundation

public enum EventStatus: String, Codable, CaseIterable {
    case upcoming
    case active
    case completed
    case skipped
    case cancelled
}
