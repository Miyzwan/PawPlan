import Foundation
import Combine
import SwiftUI
import PawPlanShared

// MARK: - View Data

public struct DashboardViewData: Equatable {
    public let upcomingEvents: [CalendarEvent]
    public let todayEventsCount: Int

    public init(upcomingEvents: [CalendarEvent], todayEventsCount: Int) {
        self.upcomingEvents = upcomingEvents
        self.todayEventsCount = todayEventsCount
    }
}

// MARK: - View State

public enum DashboardViewState: Equatable {
    case loading
    case empty
    case loaded(DashboardViewData)
    case error(AppError)
}

// MARK: - ViewModel

@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public private(set) var state: DashboardViewState = .loading

    // MARK: - Dependencies

    private let eventRepository: EventRepositoryProtocol
    private let dateProvider: DateProviderProtocol
    private let calendarProvider: CalendarProviderProtocol
    private var loadTask: Task<Void, Never>?

    // MARK: - Init

    public init(
        eventRepository: EventRepositoryProtocol,
        dateProvider: DateProviderProtocol,
        calendarProvider: CalendarProviderProtocol
    ) {
        self.eventRepository = eventRepository
        self.dateProvider = dateProvider
        self.calendarProvider = calendarProvider
    }

    // MARK: - Public Interface

    public func loadDashboard() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                if Task.isCancelled { return }

                let allEvents = try await eventRepository.fetchEvents()
                let now = dateProvider.now

                let todayEvents = allEvents.filter {
                    calendarProvider.isDate($0.startDate, inSameDayAs: now)
                }
                let upcoming = allEvents
                    .filter { $0.startDate >= now && $0.status == .upcoming }
                    .prefix(3)

                if Task.isCancelled { return }

                if allEvents.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .loaded(DashboardViewData(
                        upcomingEvents: Array(upcoming),
                        todayEventsCount: todayEvents.count
                    ))
                }
            } catch {
                if !Task.isCancelled {
                    self.state = .error(.unknown(error.localizedDescription))
                }
            }
        }
    }

    public func cancelTasks() {
        loadTask?.cancel()
    }
}
