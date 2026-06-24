import Foundation
import SwiftData
import PawPlanShared

public final class AppContainer {
    public let modelContainer: ModelContainer
    public let dateProvider: DateProviderProtocol
    public let calendarProvider: CalendarProviderProtocol
    
    public init(
        modelContainer: ModelContainer = SwiftDataModelContainer.create(),
        dateProvider: DateProviderProtocol = SystemDateProvider(),
        calendarProvider: CalendarProviderProtocol = SystemCalendarProvider()
    ) {
        self.modelContainer = modelContainer
        self.dateProvider = dateProvider
        self.calendarProvider = calendarProvider
    }
    
    // Dependency providers
    @MainActor
    public func makeRootViewModel(router: AppRouter) -> RootViewModel {
        return RootViewModel(router: router)
    }
    
    @MainActor
    public func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(dateProvider: dateProvider)
    }
    
    @MainActor
    public func makeCalendarViewModel() -> CalendarViewModel {
        return CalendarViewModel(dateProvider: dateProvider, calendarProvider: calendarProvider)
    }
    
    @MainActor
    public func makeSettingsViewModel(settings: AppSettings) -> SettingsViewModel {
        return SettingsViewModel(settings: settings)
    }
}
