import Foundation

public enum WatchSyncStatus: String, Codable {
    case upToDate
    case syncing
    case stale
    case unavailable
    case failed
}
