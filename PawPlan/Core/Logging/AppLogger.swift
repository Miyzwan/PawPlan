import Foundation
import OSLog

public final class AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.miyzwan.PawPlan"
    
    public static let general = Logger(subsystem: subsystem, category: "general")
    public static let database = Logger(subsystem: subsystem, category: "database")
    public static let notifications = Logger(subsystem: subsystem, category: "notifications")
    public static let sync = Logger(subsystem: subsystem, category: "sync")
    
    public static func debug(_ message: String, logger: Logger = general) {
        logger.debug("\(message)")
    }
    
    public static func info(_ message: String, logger: Logger = general) {
        logger.info("\(message)")
    }
    
    public static func error(_ message: String, error: Error? = nil, logger: Logger = general) {
        if let err = error {
            logger.error("\(message): \(err.localizedDescription)")
        } else {
            logger.error("\(message)")
        }
    }
}
