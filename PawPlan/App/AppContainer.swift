import Foundation
import SwiftData
import UserNotifications
import PawPlanShared

// MARK: - AppContainer
// Root dependency injection container for the iOS PawPlan target.
// All services and ViewModels are composed here.

@MainActor
public final class AppContainer {

    // MARK: - Core Dependencies

    public let modelContainer: ModelContainer
    public let dateProvider: DateProviderProtocol
    public let calendarProvider: CalendarProviderProtocol

    // MARK: - Services

    public let eventRepository: EventRepositoryProtocol
    public let eventValidationService: EventValidationServiceProtocol
    public let notificationScheduler: NotificationSchedulerProtocol
    public let notificationPermissionManager: NotificationPermissionManager
    private var notificationActionHandler: NotificationActionHandler?

    // MARK: - Init

    public init(
        modelContainer: ModelContainer = SwiftDataModelContainer.create(),
        dateProvider: DateProviderProtocol = SystemDateProvider(),
        calendarProvider: CalendarProviderProtocol = SystemCalendarProvider()
    ) {
        self.modelContainer = modelContainer
        self.dateProvider = dateProvider
        self.calendarProvider = calendarProvider
        
        let scheduler = NotificationScheduler(
            dateProvider: dateProvider,
            calendarProvider: calendarProvider
        )
        self.notificationScheduler = scheduler
        self.notificationPermissionManager = NotificationPermissionManager()
        
        self.eventRepository = EventRepository(
            modelContainer: modelContainer,
            notificationScheduler: scheduler
        )
        self.eventValidationService = EventValidationService()
    }

    public func registerNotificationDelegate() {
        let handler = NotificationActionHandler(
            eventRepository: eventRepository,
            dateProvider: dateProvider
        )
        self.notificationActionHandler = handler
        UNUserNotificationCenter.current().delegate = handler
    }

    // MARK: - ViewModel Factories

    public func makeRootViewModel(router: AppRouter) -> RootViewModel {
        return RootViewModel(router: router)
    }

    public func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(
            eventRepository: eventRepository,
            dateProvider: dateProvider,
            calendarProvider: calendarProvider
        )
    }

    public func makeCalendarViewModel() -> CalendarViewModel {
        return CalendarViewModel(
            eventRepository: eventRepository,
            dateProvider: dateProvider,
            calendarProvider: calendarProvider
        )
    }

    public func makeAgendaViewModel() -> AgendaViewModel {
        return AgendaViewModel(
            eventRepository: eventRepository,
            dateProvider: dateProvider,
            calendarProvider: calendarProvider
        )
    }

    public func makeEventEditorViewModel(eventToEdit: CalendarEvent? = nil) -> EventEditorViewModel {
        return EventEditorViewModel(
            eventRepository: eventRepository,
            validationService: eventValidationService,
            eventToEdit: eventToEdit
        )
    }

    public func makeEventDetailViewModel(event: CalendarEvent) -> EventDetailViewModel {
        return EventDetailViewModel(
            event: event,
            eventRepository: eventRepository,
            dateProvider: dateProvider
        )
    }

    public func makeSettingsViewModel(settings: AppSettings) -> SettingsViewModel {
        return SettingsViewModel(settings: settings)
    }
}
