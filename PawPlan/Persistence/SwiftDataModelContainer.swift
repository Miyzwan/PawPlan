import Foundation
import SwiftData

public final class SwiftDataModelContainer {
    public static func create(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            CalendarEventEntity.self,
            PetProfileEntity.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Gagal menginisialisasi SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
}
