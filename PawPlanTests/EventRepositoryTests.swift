import XCTest
import SwiftData
@testable import PawPlan
import PawPlanShared

// MARK: - EventRepositoryTests
// Tests for EventRepository using an in-memory SwiftData container.

@MainActor
final class EventRepositoryTests: XCTestCase {

    // MARK: - Properties

    private var container: ModelContainer!
    private var repository: EventRepository!

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        try await super.setUp()
        container = SwiftDataModelContainer.create(inMemory: true)
        repository = EventRepository(modelContainer: container)
    }

    override func tearDown() async throws {
        repository = nil
        container = nil
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func makeEvent(
        title: String = "Test Event",
        startOffset: TimeInterval = 3600,
        duration: TimeInterval = 3600
    ) -> CalendarEvent {
        let start = Date().addingTimeInterval(startOffset)
        let end = start.addingTimeInterval(duration)
        return CalendarEvent(
            title: title,
            startDate: start,
            endDate: end
        )
    }

    // MARK: - Tests: Fetch

    func testFetchEvents_WhenEmpty_ReturnsEmptyArray() async throws {
        let events = try await repository.fetchEvents()
        XCTAssertTrue(events.isEmpty, "Expected no events in an empty store")
    }

    func testFetchEvent_WhenNotFound_ReturnsNil() async throws {
        let result = try await repository.fetchEvent(by: UUID())
        XCTAssertNil(result, "Expected nil for a non-existent event ID")
    }

    // MARK: - Tests: Save (Insert)

    func testSaveEvent_Insert_EventIsStored() async throws {
        let event = makeEvent(title: "Meeting")
        try await repository.saveEvent(event)

        let fetched = try await repository.fetchEvent(by: event.id)
        XCTAssertNotNil(fetched, "Expected saved event to be retrievable by ID")
        XCTAssertEqual(fetched?.title, "Meeting")
    }

    func testSaveMultipleEvents_AllAreStoredAndFetched() async throws {
        let event1 = makeEvent(title: "Event A", startOffset: 100)
        let event2 = makeEvent(title: "Event B", startOffset: 200)
        try await repository.saveEvent(event1)
        try await repository.saveEvent(event2)

        let all = try await repository.fetchEvents()
        XCTAssertEqual(all.count, 2, "Expected exactly 2 events")
        XCTAssertTrue(all.contains(where: { $0.title == "Event A" }))
        XCTAssertTrue(all.contains(where: { $0.title == "Event B" }))
    }

    // MARK: - Tests: Save (Update / Upsert)

    func testSaveEvent_Update_OverwritesExistingEvent() async throws {
        var event = makeEvent(title: "Original Title")
        try await repository.saveEvent(event)

        // Mutate and re-save the same ID
        event.title = "Updated Title"
        event.updatedAt = Date()
        try await repository.saveEvent(event)

        let all = try await repository.fetchEvents()
        XCTAssertEqual(all.count, 1, "Expected only 1 event after update (no duplicate insert)")

        let fetched = try await repository.fetchEvent(by: event.id)
        XCTAssertEqual(fetched?.title, "Updated Title", "Expected title to be updated")
    }

    // MARK: - Tests: Delete

    func testDeleteEvent_ExistingEvent_IsRemovedFromStore() async throws {
        let event = makeEvent()
        try await repository.saveEvent(event)

        try await repository.deleteEvent(by: event.id)

        let all = try await repository.fetchEvents()
        XCTAssertTrue(all.isEmpty, "Expected store to be empty after delete")
    }

    func testDeleteEvent_NonExistentID_DoesNotThrow() async throws {
        // Should silently succeed without error
        XCTAssertNoThrow(try await repository.deleteEvent(by: UUID()))
    }

    // MARK: - Tests: Serialization

    func testSaveEvent_WithReminderOffsets_OffsetsArePreserved() async throws {
        var event = makeEvent()
        event.reminderOffsets = [.minutesBefore(10), .hoursBefore(1)]
        try await repository.saveEvent(event)

        let fetched = try await repository.fetchEvent(by: event.id)
        XCTAssertEqual(fetched?.reminderOffsets.count, 2)
        XCTAssertEqual(fetched?.reminderOffsets.first, .minutesBefore(10))
    }

    func testSaveEvent_WithRecurrenceRule_RuleIsPreserved() async throws {
        var event = makeEvent()
        event.recurrenceRule = .daily
        try await repository.saveEvent(event)

        let fetched = try await repository.fetchEvent(by: event.id)
        XCTAssertEqual(fetched?.recurrenceRule, .daily)
    }

    func testSaveEvent_WithCategory_CategoryIsPreserved() async throws {
        var event = makeEvent()
        event.category = .health
        try await repository.saveEvent(event)

        let fetched = try await repository.fetchEvent(by: event.id)
        XCTAssertEqual(fetched?.category, .health)
    }

    func testSaveEvent_WithPriority_PriorityIsPreserved() async throws {
        var event = makeEvent()
        event.priority = .urgent
        try await repository.saveEvent(event)

        let fetched = try await repository.fetchEvent(by: event.id)
        XCTAssertEqual(fetched?.priority, .urgent)
    }

    func testSaveEvent_Completed_CompletedAtIsPreserved() async throws {
        let completedDate = Date()
        var event = makeEvent()
        event.status = .completed
        event.completedAt = completedDate
        try await repository.saveEvent(event)

        let fetched = try await repository.fetchEvent(by: event.id)
        XCTAssertEqual(fetched?.status, .completed)
        XCTAssertNotNil(fetched?.completedAt)
    }
}
