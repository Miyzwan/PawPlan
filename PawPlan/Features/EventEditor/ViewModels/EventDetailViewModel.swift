import Foundation
import Combine
import PawPlanShared

@MainActor
public final class EventDetailViewModel: ObservableObject {
    @Published public private(set) var event: CalendarEvent
    @Published public var isDeleted: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let eventRepository: EventRepositoryProtocol
    private let dateProvider: DateProviderProtocol
    private var loadTask: Task<Void, Never>?
    
    public init(
        event: CalendarEvent,
        eventRepository: EventRepositoryProtocol,
        dateProvider: DateProviderProtocol
    ) {
        self.event = event
        self.eventRepository = eventRepository
        self.dateProvider = dateProvider
    }
    
    public func reloadEvent() {
        Task {
            do {
                if let updatedEvent = try await eventRepository.fetchEvent(by: event.id) {
                    self.event = updatedEvent
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func markAsCompleted() {
        var updated = event
        if updated.status == .completed {
            updated.status = .upcoming
            updated.completedAt = nil
        } else {
            updated.status = .completed
            updated.completedAt = dateProvider.now
        }
        updated.updatedAt = dateProvider.now
        saveChanges(updated)
    }
    
    public func skipEvent() {
        var updated = event
        if updated.status == .skipped {
            updated.status = .upcoming
        } else {
            updated.status = .skipped
            updated.completedAt = nil
        }
        updated.updatedAt = dateProvider.now
        saveChanges(updated)
    }
    
    public func deleteEvent() {
        Task {
            do {
                try await eventRepository.deleteEvent(by: event.id)
                self.isDeleted = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func makeDuplicateEvent() -> CalendarEvent {
        return CalendarEvent(
            id: UUID(),
            title: "Salinan: \(event.title)",
            notes: event.notes,
            startDate: dateProvider.now.addingTimeInterval(3600), // 1 hour from now
            endDate: dateProvider.now.addingTimeInterval(7200),  // 2 hours from now
            timeZoneIdentifier: event.timeZoneIdentifier,
            category: event.category,
            priority: event.priority,
            status: .upcoming,
            reminderOffsets: event.reminderOffsets,
            recurrenceRule: event.recurrenceRule,
            showInDynamicIsland: event.showInDynamicIsland,
            petReactionPreset: event.petReactionPreset,
            createdAt: dateProvider.now,
            updatedAt: dateProvider.now,
            completedAt: nil,
            source: .local,
            externalCalendarEventIdentifier: nil,
            showOnAppleWatch: event.showOnAppleWatch
        )
    }
    
    private func saveChanges(_ updatedEvent: CalendarEvent) {
        Task {
            do {
                try await eventRepository.saveEvent(updatedEvent)
                self.event = updatedEvent
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
