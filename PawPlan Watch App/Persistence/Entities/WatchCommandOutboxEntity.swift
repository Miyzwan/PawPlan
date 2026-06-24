import Foundation
import SwiftData
import Combine

@Model
public final class WatchCommandOutboxEntity {
    @Attribute(.unique) public var commandID: UUID
    public var idempotencyKey: UUID
    public var eventID: UUID
    public var commandTypeRawValue: String
    public var createdAt: Date
    public var isPending: Bool
    
    public init(
        commandID: UUID = UUID(),
        idempotencyKey: UUID = UUID(),
        eventID: UUID,
        commandTypeRawValue: String,
        createdAt: Date = Date(),
        isPending: Bool = true
    ) {
        self.commandID = commandID
        self.idempotencyKey = idempotencyKey
        self.eventID = eventID
        self.commandTypeRawValue = commandTypeRawValue
        self.createdAt = createdAt
        self.isPending = isPending
    }
}
