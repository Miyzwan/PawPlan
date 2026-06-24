import Foundation
import SwiftData
import PawPlanShared

// MARK: - EventRepository
// Concrete implementation of EventRepositoryProtocol using SwiftData.
// Runs on @MainActor to ensure thread-safe access to ModelContext.

@MainActor
public final class EventRepository: EventRepositoryProtocol {

    // MARK: - Dependencies

    private let modelContainer: ModelContainer

    private var context: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Init

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - EventRepositoryProtocol

    public func fetchEvents() async throws -> [CalendarEvent] {
        let descriptor = FetchDescriptor<CalendarEventEntity>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }

    public func fetchEvent(by id: UUID) async throws -> CalendarEvent? {
        let predicate = #Predicate<CalendarEventEntity> { $0.id == id }
        var descriptor = FetchDescriptor<CalendarEventEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        let results = try context.fetch(descriptor)
        return results.first?.toDomain()
    }

    public func saveEvent(_ event: CalendarEvent) async throws {
        // Check if event already exists (update) or is new (insert)
        let id = event.id
        let predicate = #Predicate<CalendarEventEntity> { $0.id == id }
        var descriptor = FetchDescriptor<CalendarEventEntity>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            existing.update(from: event)
        } else {
            let entity = CalendarEventEntity(from: event)
            context.insert(entity)
        }

        try context.save()
    }

    public func deleteEvent(by id: UUID) async throws {
        let predicate = #Predicate<CalendarEventEntity> { $0.id == id }
        var descriptor = FetchDescriptor<CalendarEventEntity>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let entity = try context.fetch(descriptor).first {
            context.delete(entity)
            try context.save()
        }
    }
}
