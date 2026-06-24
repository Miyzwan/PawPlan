import Foundation

public enum WatchCommandType: String, Codable {
    case completeEvent
    case skipEvent
    case snoozeReminder
    case requestFullSync
    case openEventOnPhone
}
