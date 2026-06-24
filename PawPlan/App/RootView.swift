import SwiftUI

public struct RootView: View {
    @StateObject private var viewModel: RootViewModel
    private let container: AppContainer
    private let settings: AppSettings
    
    public init(viewModel: RootViewModel, container: AppContainer, settings: AppSettings) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
        self.settings = settings
    }
    
    public var body: some View {
        TabView(selection: $viewModel.activeTab) {
            DashboardView(viewModel: container.makeDashboardViewModel())
                .tabItem {
                    Label("Dashboard", systemImage: AppIcon.dashboard)
                }
                .tag(AppRouter.AppTab.dashboard)
                .accessibilityIdentifier("tab_dashboard")
            
            CalendarView(viewModel: container.makeCalendarViewModel())
                .tabItem {
                    Label("Kalender", systemImage: AppIcon.calendar)
                }
                .tag(AppRouter.AppTab.calendar)
                .accessibilityIdentifier("tab_calendar")
            
            SettingsView(viewModel: container.makeSettingsViewModel(settings: settings))
                .tabItem {
                    Label("Pengaturan", systemImage: AppIcon.settings)
                }
                .tag(AppRouter.AppTab.settings)
                .accessibilityIdentifier("tab_settings")
        }
    }
}
