import XCTest
import PawPlanShared
@testable import PawPlan

@MainActor
final class CalendarViewModelTests: XCTestCase {
    
    private var mockDate: Date!
    private var dateProvider: MockDateProvider!
    private var calendarProvider: MockCalendarProvider!
    private var eventRepository: MockEventRepository!
    private var viewModel: CalendarViewModel!
    
    override func setUp() {
        super.setUp()
        // Use a fixed date to keep calendar grid testing deterministic
        // 2026-06-25 (Thursday)
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 25
        components.hour = 10
        components.minute = 0
        mockDate = Calendar.current.date(from: components)!
        
        dateProvider = MockDateProvider(date: mockDate)
        calendarProvider = MockCalendarProvider()
        eventRepository = MockEventRepository()
        
        viewModel = CalendarViewModel(
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
        XCTAssertEqual(viewModel.selectedDate, mockDate)
        XCTAssertEqual(viewModel.visibleDate, mockDate)
        // Grid should be pre-populated (with empty events initially)
        XCTAssertFalse(viewModel.days.isEmpty)
        XCTAssert(viewModel.days.count == 35 || viewModel.days.count == 42)
    }
    
    func testLoadCalendarPopulatesEventsInGrid() async {
        let eventDate = mockDate!
        let event = CalendarEvent(
            id: UUID(),
            title: "Test Event",
            startDate: eventDate,
            endDate: eventDate.addingTimeInterval(3600)
        )
        eventRepository.stubbedEvents = [event]
        
        viewModel.loadCalendar()
        
        // Wait for task completion
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        if case .loaded(let events) = viewModel.state {
            XCTAssertEqual(events.count, 1)
        } else {
            XCTFail("Expected loaded state")
        }
        
        // Ensure the grid cell for eventDate contains this event
        let calendar = calendarProvider.currentCalendar()
        let matchingDay = viewModel.days.first { calendar.isDate($0.date, inSameDayAs: eventDate) }
        XCTAssertNotNil(matchingDay)
        XCTAssertEqual(matchingDay?.events.count, 1)
        XCTAssertEqual(matchingDay?.events.first?.title, "Test Event")
    }
    
    func testNextAndPreviousMonth() {
        let calendar = calendarProvider.currentCalendar()
        
        viewModel.nextMonth()
        let expectedNextMonth = calendar.component(.month, from: viewModel.visibleDate)
        XCTAssertEqual(expectedNextMonth, 7) // June -> July
        
        viewModel.previousMonth()
        let expectedPrevMonth = calendar.component(.month, from: viewModel.visibleDate)
        XCTAssertEqual(expectedPrevMonth, 6) // July -> June
    }
    
    func testSelectDateInCurrentMonth() {
        let calendar = calendarProvider.currentCalendar()
        let newDate = calendar.date(byAdding: .day, value: 3, to: mockDate)!
        
        viewModel.selectDate(newDate)
        
        XCTAssertEqual(viewModel.selectedDate, newDate)
        XCTAssertEqual(viewModel.visibleDate, mockDate) // Should not change visible month since it's the same month
    }
    
    func testSelectDateInDifferentMonthShiftsVisibleMonth() {
        let calendar = calendarProvider.currentCalendar()
        let newDate = calendar.date(byAdding: .month, value: 1, to: mockDate)!
        
        viewModel.selectDate(newDate)
        
        XCTAssertEqual(viewModel.selectedDate, newDate)
        XCTAssertEqual(viewModel.visibleDate, newDate) // Should change visible month since selected month differs
    }
}
