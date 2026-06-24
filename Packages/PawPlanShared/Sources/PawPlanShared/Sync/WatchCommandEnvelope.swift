import Foundation

public struct WatchCommandEnvelope: Codable, Identifiable, Equatable {
    public var id: UUID { commandID }
    public let commandID: UUID
    public let idempotencyKey: UUID
    public let eventID: UUID
    public let commandType: WatchCommandType
    public let createdAt: Date
    public let payloadVersion: Int
    public let metadata: [String: String]
    
    public init(
        commandID: UUID = UUID(),
        idempotencyKey: UUID = UUID(),
        eventID: UUID,
        commandType: WatchCommandType,
        createdAt: Date = Date(),
        payloadVersion: Int = SyncPayloadVersion.current,
        metadata: [String: String] = [:]
    ) {
        self.commandID = commandID
        self.idempotencyKey = idempotencyKey
        self.eventID = eventID
        self.commandType = commandType
        self.createdAt = createdAt
        self.payloadVersion = payloadVersion
        self.metadata = metadata
    }
}
