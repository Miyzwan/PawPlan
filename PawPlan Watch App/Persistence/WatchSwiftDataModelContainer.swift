import Foundation
import SwiftData

public final class WatchSwiftDataModelContainer {
    public static func create(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            WatchEventSnapshotEntity.self,
            WatchPetSnapshotEntity.self,
            WatchCommandOutboxEntity.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Gagal menginisialisasi WatchSwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
}
