import Foundation
import SwiftData
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

    // MARK: - Init

    public init(
        modelContainer: ModelContainer = SwiftDataModelContainer.create(),
        dateProvider: DateProviderProtocol = SystemDateProvider(),
        calendarProvider: CalendarProviderProtocol = SystemCalendarProvider()
    ) {
        self.modelContainer = modelContainer
        self.dateProvider = dateProvider
        self.calendarProvider = calendarProvider
        self.eventRepository = EventRepository(modelContainer: modelContainer)
        self.eventValidationService = EventValidationService()
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

    public func makeSettingsViewModel(settings: AppSettings) -> SettingsViewModel {
        return SettingsViewModel(settings: settings)
    }
}
