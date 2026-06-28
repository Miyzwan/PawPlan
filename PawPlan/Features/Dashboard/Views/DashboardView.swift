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

                content
                    .navigationTitle("Dashboard")
                    .task {
                        viewModel.loadDashboard()
                    }
                    .onDisappear {
                        viewModel.cancelTasks()
                    }
                    .sheet(isPresented: $viewModel.showCustomizationSheet) {
                        PetCustomizationSheet(viewModel: viewModel)
                            .presentationDetents([.medium, .large])
                    }
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Memuat data...")
                .accessibilityIdentifier("dashboard_loading_indicator")

        case .empty:
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Pet card always shows even when no events yet
                    PetDashboardView(viewModel: viewModel)
                        .padding(.horizontal, AppSpacing.medium)
                        .padding(.top, AppSpacing.medium)

                    VStack(spacing: AppSpacing.medium) {
                        Text("Belum ada jadwal")
                            .font(AppTypography.titleMedium)
                            .foregroundColor(.secondary)
                        Text("Mulai tambahkan event untuk hari ini!")
                            .font(AppTypography.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .accessibilityIdentifier("dashboard_empty_state")
                }
            }

        case .loaded(let data):
            ScrollView {
                VStack(spacing: AppSpacing.medium) {
                    // Pet interactive card
                    PetDashboardView(viewModel: viewModel)
                        .padding(.horizontal, AppSpacing.medium)
                        .padding(.top, AppSpacing.medium)

                    // Today's summary chip
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.accentColor)
                        Text("Hari ini: \(data.todayEventsCount) event")
                            .font(AppTypography.titleSmall)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, AppSpacing.medium)
                    .padding(.vertical, AppSpacing.small)
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

                    Spacer(minLength: AppSpacing.large)
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
