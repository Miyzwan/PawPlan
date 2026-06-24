import XCTest
import UserNotifications
import PawPlanShared
@testable import PawPlan

@MainActor
final class NotificationSchedulerTests: XCTestCase {
    
    private var mockDate: Date!
    private var dateProvider: MockDateProvider!
    private var calendarProvider: MockCalendarProvider!
    private var mockNotificationCenter: MockUserNotificationCenter!
    private var scheduler: NotificationScheduler!
    
    override func setUp() {
        super.setUp()
        // Use a fixed reference date: 2026-06-25 12:00:00
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 25
        components.hour = 12
        components.minute = 0
        components.second = 0
        mockDate = Calendar.current.date(from: components)!
        
        dateProvider = MockDateProvider(date: mockDate)
        calendarProvider = MockCalendarProvider()
        mockNotificationCenter = MockUserNotificationCenter()
        
        scheduler = NotificationScheduler(
            notificationCenter: mockNotificationCenter,
            dateProvider: dateProvider,
            calendarProvider: calendarProvider
        )
    }
    
    override func tearDown() {
        scheduler = nil
        mockNotificationCenter = nil
        calendarProvider = nil
        dateProvider = nil
        super.tearDown()
    }
    
    func testScheduleReminders_AllInFuture_SchedulesCorrectly() async throws {
        // Event is at 13:00 (1 hour after mockDate)
        let eventStart = mockDate.addingTimeInterval(3600)
        let event = CalendarEvent(
            id: UUID(),
            title: "Future Event",
            startDate: eventStart,
            endDate: eventStart.addingTimeInterval(3600),
            reminderOffsets: [.atTime, .minutesBefore(15)]
        )
        
        try await scheduler.scheduleReminders(for: event)
        
        // Should cancel previous ones first, then add 2 new notifications
        XCTAssertEqual(mockNotificationCenter.addedRequests.count, 2)
        
        // Verify identifiers
        let identifiers = mockNotificationCenter.addedRequests.map { $0.identifier }
        XCTAssertTrue(identifiers.contains("event.\(event.id.uuidString).reminder.atTime"))
        XCTAssertTrue(identifiers.contains("event.\(event.id.uuidString).reminder.minutesBefore_15"))
        
        // Verify registration of category and actions
        XCTAssertEqual(mockNotificationCenter.stubbedCategories.count, 1)
        XCTAssertEqual(mockNotificationCenter.stubbedCategories.first?.identifier, "EVENT_REMINDER")
    }
    
    func testScheduleReminders_PastOffsets_FallsBackToImmediate() async throws {
        // Event is in 5 minutes
        let eventStart = mockDate.addingTimeInterval(300)
        let event = CalendarEvent(
            id: UUID(),
            title: "Soon Event",
            startDate: eventStart,
            endDate: eventStart.addingTimeInterval(3600),
            // AtTime is in future (+300s), but 15 minutes before is in past (-600s relative to mockDate)
            reminderOffsets: [.atTime, .minutesBefore(15)]
        )
        
        try await scheduler.scheduleReminders(for: event)
        
        // Both should be scheduled (atTime is standard, minutesBefore(15) falls back to immediate 1-second trigger)
        XCTAssertEqual(mockNotificationCenter.addedRequests.count, 2)
        
        let identifiers = mockNotificationCenter.addedRequests.map { $0.identifier }
        XCTAssertTrue(identifiers.contains("event.\(event.id.uuidString).reminder.atTime"))
        XCTAssertTrue(identifiers.contains("event.\(event.id.uuidString).reminder.minutesBefore_15"))
        
        // The one that falls back to immediate should have a UNTimeIntervalNotificationTrigger of 1 second
        let fallbackRequest = mockNotificationCenter.addedRequests.first { $0.identifier.contains("minutesBefore_15") }
        XCTAssertNotNil(fallbackRequest)
        let trigger = fallbackRequest?.trigger as? UNTimeIntervalNotificationTrigger
        XCTAssertEqual(trigger?.timeInterval, 1.0)
    }
    
    func testScheduleReminders_InactiveEventStatus_DoesNotSchedule() async throws {
        let eventStart = mockDate.addingTimeInterval(3600)
        
        // Completed Event
        let eventCompleted = CalendarEvent(
            id: UUID(),
            title: "Done Event",
            startDate: eventStart,
            endDate: eventStart.addingTimeInterval(3600),
            status: .completed,
            reminderOffsets: [.atTime]
        )
        
        try await scheduler.scheduleReminders(for: eventCompleted)
        XCTAssertEqual(mockNotificationCenter.addedRequests.count, 0)
        
        // Skipped Event
        let eventSkipped = CalendarEvent(
            id: UUID(),
            title: "Skipped Event",
            startDate: eventStart,
            endDate: eventStart.addingTimeInterval(3600),
            status: .skipped,
            reminderOffsets: [.atTime]
        )
        
        try await scheduler.scheduleReminders(for: eventSkipped)
        XCTAssertEqual(mockNotificationCenter.addedRequests.count, 0)
    }
    
    func testCancelReminders_RemovesCorrectRequests() async throws {
        let event = CalendarEvent(
            id: UUID(),
            title: "Event to Cancel",
            startDate: mockDate.addingTimeInterval(3600),
            endDate: mockDate.addingTimeInterval(7200),
            reminderOffsets: [.atTime, .minutesBefore(5)]
        )
        
        // 1. Pre-populate mock center
        try await scheduler.scheduleReminders(for: event)
        XCTAssertEqual(mockNotificationCenter.addedRequests.count, 2)
        
        // 2. Cancel reminders
        try await scheduler.cancelReminders(for: event)
        
        // 3. Verify removed
        XCTAssertEqual(mockNotificationCenter.addedRequests.count, 0)
        XCTAssertEqual(mockNotificationCenter.pendingIdentifiersToRemove.count, 2) // Cancel at schedule, and manual cancel
    }
    
    func testReconcileReminders_ReschedulesAllActiveUpcomingEvents() async throws {
        let eventStart = mockDate.addingTimeInterval(3600)
        let e1 = CalendarEvent(title: "Active 1", startDate: eventStart, endDate: eventStart.addingTimeInterval(3600), status: .upcoming, reminderOffsets: [.atTime])
        let e2 = CalendarEvent(title: "Completed", startDate: eventStart, endDate: eventStart.addingTimeInterval(3600), status: .completed, reminderOffsets: [.atTime])
        let e3 = CalendarEvent(title: "Active 2", startDate: eventStart, endDate: eventStart.addingTimeInterval(3600), status: .active, reminderOffsets: [.atTime])
        
        try await scheduler.reconcileReminders(with: [e1, e2, e3])
        
        // Should clear all first, then reschedule e1 and e3
        XCTAssertEqual(mockNotificationCenter.allPendingRemovedCount, 1)
        XCTAssertEqual(mockNotificationCenter.addedRequests.count, 2)
        
        let titles = mockNotificationCenter.addedRequests.map { $0.content.title }
        XCTAssertTrue(titles.contains("Active 1"))
        XCTAssertTrue(titles.contains("Active 2"))
        XCTAssertFalse(titles.contains("Completed"))
    }
}
