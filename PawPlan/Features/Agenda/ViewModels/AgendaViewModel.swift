import Foundation
import Combine
import PawPlanShared

// MARK: - View State

public struct AgendaGroup: Equatable, Identifiable {
    public var id: Date { date }
    public let date: Date
    public let events: [CalendarEvent]
    
    public init(date: Date, events: [CalendarEvent]) {
        self.date = date
        self.events = events
    }
}

public enum AgendaViewState: Equatable {
    case loading
    case empty
    case loaded([AgendaGroup])
    case error(AppError)
}

// MARK: - ViewModel

@MainActor
public final class AgendaViewModel: ObservableObject {
    @Published public private(set) var state: AgendaViewState = .loading
    @Published public var selectedFilter: AgendaFilter = .all {
        didSet {
            applyFilter()
        }
    }
    
    private let eventRepository: EventRepositoryProtocol
    private let dateProvider: DateProviderProtocol
    private let calendarProvider: CalendarProviderProtocol
    
    private var allEvents: [CalendarEvent] = []
    private var loadTask: Task<Void, Never>?
    
    public init(
        eventRepository: EventRepositoryProtocol,
        dateProvider: DateProviderProtocol,
        calendarProvider: CalendarProviderProtocol
    ) {
        self.eventRepository = eventRepository
        self.dateProvider = dateProvider
        self.calendarProvider = calendarProvider
    }
    
    public func loadEvents() {
        loadTask?.cancel()
        state = .loading
        
        loadTask = Task {
            do {
                if Task.isCancelled { return }
                let events = try await eventRepository.fetchEvents()
                if Task.isCancelled { return }
                self.allEvents = events
                self.applyFilter()
            } catch {
                if !Task.isCancelled {
                    self.state = .error(.unknown(error.localizedDescription))
                }
            }
        }
    }
    
    public func toggleEventCompletion(_ event: CalendarEvent) {
        Task {
            var updated = event
            if updated.status == .completed {
                updated.status = .upcoming
                updated.completedAt = nil
            } else {
                updated.status = .completed
                updated.completedAt = dateProvider.now
            }
            updated.updatedAt = dateProvider.now
            
            do {
                try await eventRepository.saveEvent(updated)
                // Reload list to reflect changes
                loadEvents()
            } catch {
                self.state = .error(.unknown(error.localizedDescription))
            }
        }
    }
    
    public func cancelTasks() {
        loadTask?.cancel()
    }
    
    // MARK: - Private Helpers
    
    private func applyFilter() {
        let now = dateProvider.now
        let calendar = calendarProvider.currentCalendar()
        let todayStart = calendar.startOfDay(for: now)
        
        // 1. Filter events
        let filtered: [CalendarEvent]
        switch selectedFilter {
        case .all:
            filtered = allEvents
        case .today:
            filtered = allEvents.filter {
                calendar.isDate($0.startDate, inSameDayAs: now)
            }
        case .upcoming:
            // Events that are upcoming or active starting today or in the future
            filtered = allEvents.filter {
                $0.status == .upcoming && calendar.startOfDay(for: $0.startDate) >= todayStart
            }
        case .completed:
            filtered = allEvents.filter { $0.status == .completed }
        case .highPriority:
            filtered = allEvents.filter { $0.priority == .high || $0.priority == .urgent }
        }
        
        if filtered.isEmpty {
            self.state = .empty
            return
        }
        
        // 2. Group by date
        let grouped = Dictionary(grouping: filtered) { event -> Date in
            calendar.startOfDay(for: event.startDate)
        }
        
        // 3. Convert to sorted AgendaGroup array
        let sortedGroups = grouped.map { (date, events) -> AgendaGroup in
            let sortedEvents = events.sorted { $0.startDate < $1.startDate }
            return AgendaGroup(date: date, events: sortedEvents)
        }.sorted { $0.date < $1.date }
        
        self.state = .loaded(sortedGroups)
    }
}
