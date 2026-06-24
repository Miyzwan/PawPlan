import Foundation

public struct WatchSyncSnapshot: Codable, Equatable {
    public let schemaVersion: Int
    public let syncID: UUID
    public let generatedAt: Date
    public let sourceDeviceIdentifier: String
    public var activeEvent: WatchEventSnapshot?
    public var nextEvent: WatchEventSnapshot?
    public var todayEvents: [WatchEventSnapshot]
    public var pet: WatchPetSnapshot
    public var lastSuccessfulSyncAt: Date?
    public var syncStatus: WatchSyncStatus
    
    public init(
        schemaVersion: Int = SyncPayloadVersion.current,
        syncID: UUID = UUID(),
        generatedAt: Date = Date(),
        sourceDeviceIdentifier: String,
        activeEvent: WatchEventSnapshot? = nil,
        nextEvent: WatchEventSnapshot? = nil,
        todayEvents: [WatchEventSnapshot] = [],
        pet: WatchPetSnapshot,
        lastSuccessfulSyncAt: Date? = nil,
        syncStatus: WatchSyncStatus = .upToDate
    ) {
        self.schemaVersion = schemaVersion
        self.syncID = syncID
        self.generatedAt = generatedAt
        self.sourceDeviceIdentifier = sourceDeviceIdentifier
        self.activeEvent = activeEvent
        self.nextEvent = nextEvent
        self.todayEvents = todayEvents
        self.pet = pet
        self.lastSuccessfulSyncAt = lastSuccessfulSyncAt
        self.syncStatus = syncStatus
    }
}
