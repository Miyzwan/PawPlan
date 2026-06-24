import Foundation
import Combine
import PawPlanShared

@MainActor
public final class EventEditorViewModel: ObservableObject {
    @Published public var formState: EventEditorFormState
    @Published public var errorMessage: String? = nil
    @Published public var isSaved: Bool = false
    
    public let eventToEdit: CalendarEvent?
    public var isEditMode: Bool { eventToEdit != nil }
    
    private let eventRepository: EventRepositoryProtocol
    private let validationService: EventValidationServiceProtocol
    
    public init(
        eventRepository: EventRepositoryProtocol,
        validationService: EventValidationServiceProtocol,
        eventToEdit: CalendarEvent? = nil
    ) {
        self.eventRepository = eventRepository
        self.validationService = validationService
        self.eventToEdit = eventToEdit
        
        if let event = eventToEdit {
            self.formState = EventEditorFormState(from: event)
        } else {
            self.formState = EventEditorFormState()
        }
    }
    
    public func updateStartDate(_ date: Date) {
        formState.startDate = date
        if formState.endDate <= date {
            formState.endDate = date.addingTimeInterval(3600)
        }
    }
    
    public func save() {
        errorMessage = nil
        
        // 1. Validate inputs
        switch validationService.validate(title: formState.title, startDate: formState.startDate, endDate: formState.endDate) {
        case .failure(let error):
            errorMessage = error.localizedDescription
            return
        case .success:
            break
        }
        
        // 2. Build domain model
        let event: CalendarEvent
        if let existing = eventToEdit {
            event = CalendarEvent(
                id: existing.id,
                title: formState.title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: formState.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : formState.notes,
                startDate: formState.startDate,
                endDate: formState.endDate,
                timeZoneIdentifier: formState.timeZoneIdentifier,
                category: formState.category,
                priority: formState.priority,
                status: existing.status,
                reminderOffsets: formState.reminderOffsets,
                recurrenceRule: formState.recurrenceRule,
                showInDynamicIsland: formState.showInDynamicIsland,
                petReactionPreset: formState.petReactionPreset,
                createdAt: existing.createdAt,
                updatedAt: Date(),
                completedAt: existing.completedAt,
                source: existing.source,
                externalCalendarEventIdentifier: existing.externalCalendarEventIdentifier,
                showOnAppleWatch: formState.showOnAppleWatch
            )
        } else {
            event = formState.toCalendarEvent()
        }
        
        // 3. Save to repository
        Task {
            do {
                if !formState.reminderOffsets.isEmpty {
                    let permissionManager = NotificationPermissionManager()
                    _ = try? await permissionManager.requestPermission()
                }
                try await eventRepository.saveEvent(event)
                self.isSaved = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
