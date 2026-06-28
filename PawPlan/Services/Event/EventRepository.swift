import Foundation
import SwiftData
import PawPlanShared

// MARK: - DummyNotificationScheduler
// Fallback scheduler for test environments or environments that don't need notifications.
public final class DummyNotificationScheduler: NotificationSchedulerProtocol {
    public init() {}
    public func scheduleReminders(for event: CalendarEvent) async throws {}
    public func cancelReminders(for event: CalendarEvent) async throws {}
    public func reconcileReminders(with events: [CalendarEvent]) async throws {}
}

// MARK: - DummyPetRepository
// Fallback pet repository for test environments that don't need persistence.
public final class DummyPetRepository: PetRepositoryProtocol {
    public init() {}
    public func fetchPetProfile() async throws -> PetProfile? { nil }
    public func savePetProfile(_ profile: PetProfile) async throws {}
}

// MARK: - DummyPetStateEngine
// Fallback state engine for test environments.
public final class DummyPetStateEngine: PetStateEngineProtocol {
    public init() {}
    public func awardXP(_ points: Int, to pet: PetProfile) -> PetProfile { pet }
    public func updateStreak(for pet: PetProfile, completionDate: Date) -> PetProfile { pet }
    public func interact(action: PetAction, with pet: PetProfile) -> (PetProfile, String) { (pet, "") }
    public func resolveMood(activeEvent: CalendarEvent?, nextEvent: CalendarEvent?, currentDate: Date) -> PetMood { .idle }
    public func feedPet(_ pet: PetProfile) -> (PetProfile, String) { (pet, "") }
    public func playWithPet(_ pet: PetProfile) -> (PetProfile, String) { (pet, "") }
}

// MARK: - EventRepository
// Concrete implementation of EventRepositoryProtocol using SwiftData.
// Runs on @MainActor to ensure thread-safe access to ModelContext.
// Integrates with PetRepository and PetStateEngine to award XP when events
// are marked as completed.

@MainActor
public final class EventRepository: EventRepositoryProtocol {

    // MARK: - Dependencies

    private let modelContainer: ModelContainer
    private let notificationScheduler: NotificationSchedulerProtocol
    private let petRepository: PetRepositoryProtocol
    private let petStateEngine: PetStateEngineProtocol

    private var context: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Init

    public init(
        modelContainer: ModelContainer,
        notificationScheduler: NotificationSchedulerProtocol = DummyNotificationScheduler(),
        petRepository: PetRepositoryProtocol = DummyPetRepository(),
        petStateEngine: PetStateEngineProtocol = DummyPetStateEngine()
    ) {
        self.modelContainer = modelContainer
        self.notificationScheduler = notificationScheduler
        self.petRepository = petRepository
        self.petStateEngine = petStateEngine
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
        // Fetch old event status before saving to detect transitions
        let oldEvent = try await fetchEvent(by: event.id)
        let wasCompleted = oldEvent?.status == .completed
        let isNowCompleted = event.status == .completed

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

        // Award XP and update streak when an event is newly completed
        if !wasCompleted && isNowCompleted {
            await awardPetXPForCompletion()
        }

        // Sync local notification reminders
        if event.status == .completed || event.status == .skipped || event.status == .cancelled {
            try await notificationScheduler.cancelReminders(for: event)
        } else {
            try await notificationScheduler.scheduleReminders(for: event)
        }
    }

    public func deleteEvent(by id: UUID) async throws {
        let predicate = #Predicate<CalendarEventEntity> { $0.id == id }
        var descriptor = FetchDescriptor<CalendarEventEntity>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let entity = try context.fetch(descriptor).first {
            let event = entity.toDomain()
            context.delete(entity)
            try context.save()

            // Cancel reminders for deleted event
            try await notificationScheduler.cancelReminders(for: event)
        }
    }

    // MARK: - Pet XP Integration

    private func awardPetXPForCompletion() async {
        do {
            guard var pet = try await petRepository.fetchPetProfile() else { return }
            pet = petStateEngine.awardXP(20, to: pet)
            pet = petStateEngine.updateStreak(for: pet, completionDate: Date())
            try await petRepository.savePetProfile(pet)
        } catch {
            // Non-critical: pet XP award failures should not surface to the user
        }
    }
}
