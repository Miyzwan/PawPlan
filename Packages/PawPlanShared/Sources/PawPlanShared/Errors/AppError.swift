import Foundation

public enum AppError: Error, LocalizedError, Equatable {
    case validationFailed(String)
    case databaseError(String)
    case notificationError(String)
    case syncError(String)
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return "Validasi gagal: \(message)"
        case .databaseError(let message):
            return "Kesalahan database: \(message)"
        case .notificationError(let message):
            return "Kesalahan notifikasi: \(message)"
        case .syncError(let message):
            return "Kesalahan sinkronisasi: \(message)"
        case .unknown(let message):
            return "Kesalahan tidak dikenal: \(message)"
        }
    }
}
