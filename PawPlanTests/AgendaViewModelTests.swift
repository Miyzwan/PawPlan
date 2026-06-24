import XCTest
import PawPlanShared
@testable import PawPlan

@MainActor
final class AgendaViewModelTests: XCTestCase {
    
    private var mockDate: Date!
    private var dateProvider: MockDateProvider!
    private var calendarProvider: MockCalendarProvider!
    private var eventRepository: MockEventRepository!
    private var viewModel: AgendaViewModel!
    
    override func setUp() {
        super.setUp()
        // 2026-06-25 (Thursday)
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 25
        components.hour = 12
        components.minute = 0
        mockDate = Calendar.current.date(from: components)!
        
        dateProvider = MockDateProvider(date: mockDate)
        calendarProvider = MockCalendarProvider()
        eventRepository = MockEventRepository()
        
        viewModel = AgendaViewModel(
            eventRepository: eventRepository,
            dateProvider: dateProvider,
            calendarProvider: calendarProvider
        )
    }
    
    override func tearDown() {
        viewModel = nil
        eventRepository = nil
        calendarProvider = nil
        dateProvider = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertEqual(viewModel.selectedFilter, .all)
    }
    
    func testLoadEvents_EmptyState() async {
        eventRepository.stubbedEvents = []
        viewModel.loadEvents()
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(viewModel.state, .empty)
    }
    
    func testLoadEvents_GroupedAndSortedChronologically() async {
        // Create events on different days
        let calendar = calendarProvider.currentCalendar()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: mockDate)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: mockDate)!
        
        let e1 = CalendarEvent(title: "Today Event", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600))
        let e2 = CalendarEvent(title: "Tomorrow Event", startDate: tomorrow, endDate: tomorrow.addingTimeInterval(3600))
        let e3 = CalendarEvent(title: "Yesterday Event", startDate: yesterday, endDate: yesterday.addingTimeInterval(3600))
        
        eventRepository.stubbedEvents = [e2, e1, e3] // unsorted input
        viewModel.loadEvents()
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        guard case .loaded(let groups) = viewModel.state else {
            XCTFail("Expected loaded state")
            return
        }
        
        XCTAssertEqual(groups.count, 3)
        // Group order should be Yesterday -> Today -> Tomorrow
        XCTAssert(calendar.isDate(groups[0].date, inSameDayAs: yesterday))
        XCTAssert(calendar.isDate(groups[1].date, inSameDayAs: mockDate))
        XCTAssert(calendar.isDate(groups[2].date, inSameDayAs: tomorrow))
    }
    
    func testFilterToday() async {
        let calendar = calendarProvider.currentCalendar()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: mockDate)!
        
        let e1 = CalendarEvent(title: "Today Event", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600))
        let e2 = CalendarEvent(title: "Tomorrow Event", startDate: tomorrow, endDate: tomorrow.addingTimeInterval(3600))
        
        eventRepository.stubbedEvents = [e1, e2]
        viewModel.selectedFilter = .today
        viewModel.loadEvents()
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        guard case .loaded(let groups) = viewModel.state else {
            XCTFail("Expected loaded state")
            return
        }
        
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].events.count, 1)
        XCTAssertEqual(groups[0].events.first?.title, "Today Event")
    }
    
    func testFilterUpcoming() async {
        let calendar = calendarProvider.currentCalendar()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: mockDate)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: mockDate)!
        
        let e1 = CalendarEvent(title: "Yesterday Event", startDate: yesterday, endDate: yesterday.addingTimeInterval(3600), status: .upcoming)
        let e2 = CalendarEvent(title: "Today Event", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600), status: .upcoming)
        let e3 = CalendarEvent(title: "Tomorrow Event Completed", startDate: tomorrow, endDate: tomorrow.addingTimeInterval(3600), status: .completed)
        
        eventRepository.stubbedEvents = [e1, e2, e3]
        viewModel.selectedFilter = .upcoming
        viewModel.loadEvents()
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        guard case .loaded(let groups) = viewModel.state else {
            XCTFail("Expected loaded state")
            return
        }
        
        // Only Today Event (e2) should appear. Yesterday (e1) is in the past, and Tomorrow (e3) is completed.
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].events.count, 1)
        XCTAssertEqual(groups[0].events.first?.title, "Today Event")
    }
    
    func testFilterCompleted() async {
        let e1 = CalendarEvent(title: "Upcoming Event", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600), status: .upcoming)
        let e2 = CalendarEvent(title: "Completed Event", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600), status: .completed)
        
        eventRepository.stubbedEvents = [e1, e2]
        viewModel.selectedFilter = .completed
        viewModel.loadEvents()
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        guard case .loaded(let groups) = viewModel.state else {
            XCTFail("Expected loaded state")
            return
        }
        
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].events.count, 1)
        XCTAssertEqual(groups[0].events.first?.title, "Completed Event")
    }
    
    func testFilterHighPriority() async {
        let e1 = CalendarEvent(title: "Low Priority", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600), priority: .low)
        let e2 = CalendarEvent(title: "Normal Priority", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600), priority: .normal)
        let e3 = CalendarEvent(title: "High Priority", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600), priority: .high)
        let e4 = CalendarEvent(title: "Urgent Priority", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600), priority: .urgent)
        
        eventRepository.stubbedEvents = [e1, e2, e3, e4]
        viewModel.selectedFilter = .highPriority
        viewModel.loadEvents()
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        guard case .loaded(let groups) = viewModel.state else {
            XCTFail("Expected loaded state")
            return
        }
        
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].events.count, 2)
        XCTAssertEqual(groups[0].events[0].title, "High Priority")
        XCTAssertEqual(groups[0].events[1].title, "Urgent Priority")
    }
    
    func testToggleEventCompletion() async {
        let event = CalendarEvent(title: "My Event", startDate: mockDate, endDate: mockDate.addingTimeInterval(3600), status: .upcoming)
        eventRepository.stubbedEvents = [event]
        
        viewModel.loadEvents()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        viewModel.toggleEventCompletion(event)
        try? await Task.sleep(nanoseconds: 80_000_000)
        
        // Repository should now contain the completed event
        let savedEvent = eventRepository.stubbedEvents.first
        XCTAssertEqual(savedEvent?.status, .completed)
        XCTAssertNotNil(savedEvent?.completedAt)
    }
}
