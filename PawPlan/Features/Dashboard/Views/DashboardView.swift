import SwiftUI
import PawPlanShared

public struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    public init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()

                VStack(spacing: AppSpacing.large) {
                    switch viewModel.state {
                    case .loading:
                        ProgressView("Memuat data...")
                            .accessibilityIdentifier("dashboard_loading_indicator")

                    case .empty:
                        VStack(spacing: AppSpacing.medium) {
                            Text("🐾")
                                .font(.system(size: 80))
                            Text("Belum ada jadwal")
                                .font(AppTypography.titleMedium)
                                .foregroundColor(.secondary)
                            Text("Mulai tambahkan event untuk hari ini!")
                                .font(AppTypography.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .accessibilityIdentifier("dashboard_empty_state")

                    case .loaded(let data):
                        ScrollView {
                            VStack(spacing: AppSpacing.medium) {
                                // Pet visual card
                                VStack(spacing: AppSpacing.small) {
                                    Text("🐶")
                                        .font(.system(size: 100))
                                        .padding(.top, AppSpacing.medium)
                                    Text("Hari ini: \(data.todayEventsCount) event")
                                        .font(AppTypography.titleMedium)
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(AppRadius.medium)
                                .appShadow(.light)
                                .padding(.horizontal, AppSpacing.medium)

                                // Upcoming events list
                                if !data.upcomingEvents.isEmpty {
                                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                                        Text("Event Mendatang")
                                            .font(AppTypography.titleSmall)
                                            .foregroundColor(.primary)

                                        ForEach(data.upcomingEvents) { event in
                                            UpcomingEventRow(event: event)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(AppRadius.medium)
                                    .appShadow(.light)
                                    .padding(.horizontal, AppSpacing.medium)
                                }

                                Spacer()
                            }
                        }
                        .accessibilityIdentifier("dashboard_loaded_content")

                    case .error(let error):
                        VStack(spacing: AppSpacing.medium) {
                            Image(systemName: AppIcon.warning)
                                .foregroundColor(.red)
                                .font(.largeTitle)
                            Text(error.localizedDescription)
                                .font(AppTypography.body)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
                .navigationTitle("Dashboard")
                .task {
                    viewModel.loadDashboard()
                }
                .onDisappear {
                    viewModel.cancelTasks()
                }
            }
        }
    }
}

// MARK: - Subcomponents

private struct UpcomingEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: event.category.sfSymbol)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(AppTypography.body)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(event.startDate, style: .relative)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
