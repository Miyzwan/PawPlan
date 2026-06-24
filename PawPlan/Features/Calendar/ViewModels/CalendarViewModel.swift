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
    @Published public private(set) var days: [CalendarDayViewData] = []
    
    @Published public var selectedDate: Date {
        didSet {
            generateDays()
        }
    }
    
    @Published public var visibleDate: Date {
        didSet {
            generateDays()
        }
    }

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
        
        let now = dateProvider.now
        self.selectedDate = now
        self.visibleDate = now
        
        generateDays()
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
                self.generateDays()
            } catch {
                if !Task.isCancelled {
                    self.state = .error(.unknown(error.localizedDescription))
                }
            }
        }
    }
    
    public func selectDate(_ date: Date) {
        self.selectedDate = date
        // If selected date is in a different month than currently visible, we also shift the visible date
        let calendar = calendarProvider.currentCalendar()
        let selectedMonth = calendar.component(.month, from: date)
        let visibleMonth = calendar.component(.month, from: visibleDate)
        let selectedYear = calendar.component(.year, from: date)
        let visibleYear = calendar.component(.year, from: visibleDate)
        
        if selectedMonth != visibleMonth || selectedYear != visibleYear {
            self.visibleDate = date
        }
    }

    public func nextMonth() {
        let calendar = calendarProvider.currentCalendar()
        if let newDate = calendar.date(byAdding: .month, value: 1, to: visibleDate) {
            self.visibleDate = newDate
        }
    }

    public func previousMonth() {
        let calendar = calendarProvider.currentCalendar()
        if let newDate = calendar.date(byAdding: .month, value: -1, to: visibleDate) {
            self.visibleDate = newDate
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
    
    // MARK: - Private Helpers

    public func generateDays() {
        let calendar = calendarProvider.currentCalendar()
        
        // Start of the visible month
        guard let monthRange = calendar.range(of: .day, in: .month, for: visibleDate),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: visibleDate)) else {
            return
        }
        
        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth)
        let firstWeekday = calendar.firstWeekday
        let paddingDays = (weekdayOfFirst - firstWeekday + 7) % 7
        
        var gridDays: [CalendarDayViewData] = []
        let today = dateProvider.now
        
        let allEvents: [CalendarEvent]
        if case .loaded(let loadedEvents) = state {
            allEvents = loadedEvents
        } else {
            allEvents = []
        }
        
        // 1. Add padding days from previous month
        if let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth),
           let prevMonthRange = calendar.range(of: .day, in: .month, for: startOfPreviousMonth) {
            let totalDaysInPrevMonth = prevMonthRange.count
            let startDay = totalDaysInPrevMonth - paddingDays + 1
            if startDay <= totalDaysInPrevMonth {
                for i in startDay...totalDaysInPrevMonth {
                    var components = calendar.dateComponents([.year, .month], from: startOfPreviousMonth)
                    components.day = i
                    if let date = calendar.date(from: components) {
                        let dayEvents = allEvents.filter { calendarProvider.isDate($0.startDate, inSameDayAs: date) }
                        gridDays.append(CalendarDayViewData(
                            date: date,
                            dayNumber: "\(i)",
                            isCurrentMonth: false,
                            isToday: calendar.isDate(date, inSameDayAs: today),
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            events: dayEvents
                        ))
                    }
                }
            }
        }
        
        // 2. Add days of the current month
        for i in 1...monthRange.count {
            var components = calendar.dateComponents([.year, .month], from: startOfMonth)
            components.day = i
            if let date = calendar.date(from: components) {
                let dayEvents = allEvents.filter { calendarProvider.isDate($0.startDate, inSameDayAs: date) }
                gridDays.append(CalendarDayViewData(
                    date: date,
                    dayNumber: "\(i)",
                    isCurrentMonth: true,
                    isToday: calendar.isDate(date, inSameDayAs: today),
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    events: dayEvents
                ))
            }
        }
        
        // 3. Add padding days from next month to make multiple of 7 (usually 35 or 42 cells)
        let totalCells = gridDays.count > 35 ? 42 : 35
        let nextMonthPadding = totalCells - gridDays.count
        if nextMonthPadding > 0, let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) {
            for i in 1...nextMonthPadding {
                var components = calendar.dateComponents([.year, .month], from: startOfNextMonth)
                components.day = i
                if let date = calendar.date(from: components) {
                    let dayEvents = allEvents.filter { calendarProvider.isDate($0.startDate, inSameDayAs: date) }
                    gridDays.append(CalendarDayViewData(
                        date: date,
                        dayNumber: "\(i)",
                        isCurrentMonth: false,
                        isToday: calendar.isDate(date, inSameDayAs: today),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        events: dayEvents
                    ))
                }
            }
        }
        
        self.days = gridDays
    }
}
