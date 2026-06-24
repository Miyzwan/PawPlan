import Foundation
import Combine
import SwiftUI
import PawPlanShared

// MARK: - View State

public enum CalendarViewState: Equatable {
    case loading
    case loaded([CalendarEvent])
    case error(AppError)
}

// MARK: - ViewModel

@MainActor
public final class CalendarViewModel: ObservableObject {
    @Published public private(set) var state: CalendarViewState = .loading
    @Published public var selectedDate: Date

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
        self.selectedDate = dateProvider.now
    }

    // MARK: - Public Interface

    public func loadCalendar() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                if Task.isCancelled { return }
                let events = try await eventRepository.fetchEvents()
                if Task.isCancelled { return }
                self.state = .loaded(events)
            } catch {
                if !Task.isCancelled {
                    self.state = .error(.unknown(error.localizedDescription))
                }
            }
        }
    }

    /// Returns events for a given date.
    public func events(for date: Date) -> [CalendarEvent] {
        guard case .loaded(let allEvents) = state else { return [] }
        return allEvents.filter { calendarProvider.isDate($0.startDate, inSameDayAs: date) }
    }

    public func cancelTasks() {
        loadTask?.cancel()
    }
}
