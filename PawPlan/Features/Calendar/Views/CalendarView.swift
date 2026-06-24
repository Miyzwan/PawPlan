import SwiftUI
import PawPlanShared

public struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    private let container: AppContainer
    
    @State private var displayMode: CalendarDisplayMode = .calendar
    @State private var isShowingEditor = false
    
    public init(viewModel: CalendarViewModel, container: AppContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented picker for Mode
                Picker("Tampilan", selection: $displayMode) {
                    ForEach(CalendarDisplayMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
                
                // Content based on Mode
                if displayMode == .calendar {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Monthly Grid Calendar
                            MonthlyCalendarView(viewModel: viewModel)
                                .padding(.horizontal)
                                .padding(.top, 12)
                            
                            // Selected day header
                            HStack {
                                Text(DateTimeFormatterService.shared.formatFullDate(viewModel.selectedDate))
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Selected Day Events List
                            let dayEvents = viewModel.events(for: viewModel.selectedDate)
                            if dayEvents.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 30))
                                        .foregroundColor(.secondary.opacity(0.4))
                                    Text("Tidak ada agenda untuk hari ini.")
                                        .font(AppTypography.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.medium)
                                        .fill(AppColorToken.cardBackground.opacity(0.4))
                                        .padding(.horizontal)
                                )
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(dayEvents) { event in
                                        NavigationLink(destination: EventDetailView(viewModel: container.makeEventDetailViewModel(event: event), container: container)) {
                                            AgendaEventRow(event: event) {
                                                toggleEventCompletion(event)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    AgendaView(viewModel: container.makeAgendaViewModel(), container: container)
                }
            }
            .background(AppColorToken.background)
            .navigationTitle("Kalender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingEditor = true
                    }) {
                        Image(systemName: AppIcon.add)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(AppColorToken.primary)
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("btn_add_event")
                }
            }
            .sheet(isPresented: $isShowingEditor, onDismiss: {
                viewModel.loadCalendar()
            }) {
                EventEditorView(viewModel: container.makeEventEditorViewModel())
            }
            .task {
                viewModel.loadCalendar()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
        }
    }
    
    private func toggleEventCompletion(_ event: CalendarEvent) {
        Task {
            var updated = event
            if updated.status == .completed {
                updated.status = .upcoming
                updated.completedAt = nil
            } else {
                updated.status = .completed
                updated.completedAt = container.dateProvider.now
            }
            updated.updatedAt = container.dateProvider.now
            
            do {
                try await container.eventRepository.saveEvent(updated)
                viewModel.loadCalendar()
            } catch {
                // error logging
            }
        }
    }
}
