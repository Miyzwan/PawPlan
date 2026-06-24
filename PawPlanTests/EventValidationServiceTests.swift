import XCTest
@testable import PawPlan
import PawPlanShared

// MARK: - EventValidationServiceTests
// Tests for EventValidationService business rules (title and date range validation).

final class EventValidationServiceTests: XCTestCase {

    // MARK: - Properties

    private var service: EventValidationService!

    // MARK: - Setup / Teardown

    override func setUp() {
        super.setUp()
        service = EventValidationService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeValidDates() -> (start: Date, end: Date) {
        let start = Date()
        let end = start.addingTimeInterval(3600) // +1 hour
        return (start, end)
    }

    // MARK: - Title Validation

    func testValidate_EmptyTitle_ReturnsValidationFailure() {
        let (start, end) = makeValidDates()
        let result = service.validate(title: "", startDate: start, endDate: end)

        switch result {
        case .failure(let error):
            if case .validationFailed = error {
                // Expected
            } else {
                XCTFail("Expected validationFailed error, got \(error)")
            }
        case .success:
            XCTFail("Expected failure for empty title")
        }
    }

    func testValidate_WhitespaceOnlyTitle_ReturnsValidationFailure() {
        let (start, end) = makeValidDates()
        let result = service.validate(title: "   \t\n", startDate: start, endDate: end)

        switch result {
        case .failure(let error):
            if case .validationFailed = error {
                // Expected
            } else {
                XCTFail("Expected validationFailed error, got \(error)")
            }
        case .success:
            XCTFail("Expected failure for whitespace-only title")
        }
    }

    func testValidate_ValidTitle_ReturnsSuccess() {
        let (start, end) = makeValidDates()
        let result = service.validate(title: "Team Meeting", startDate: start, endDate: end)

        XCTAssertEqual(result, .success(()), "Expected success for valid title")
    }

    // MARK: - Date Range Validation

    func testValidate_EndDateBeforeStartDate_ReturnsValidationFailure() {
        let start = Date()
        let end = start.addingTimeInterval(-3600) // end is BEFORE start

        let result = service.validate(title: "Test Event", startDate: start, endDate: end)

        switch result {
        case .failure(let error):
            if case .validationFailed = error {
                // Expected
            } else {
                XCTFail("Expected validationFailed error, got \(error)")
            }
        case .success:
            XCTFail("Expected failure when end date is before start date")
        }
    }

    func testValidate_EndDateEqualToStartDate_ReturnsValidationFailure() {
        let date = Date()
        let result = service.validate(title: "Test Event", startDate: date, endDate: date)

        switch result {
        case .failure(let error):
            if case .validationFailed = error {
                // Expected
            } else {
                XCTFail("Expected validationFailed error, got \(error)")
            }
        case .success:
            XCTFail("Expected failure when end date equals start date")
        }
    }

    func testValidate_ValidDateRange_ReturnsSuccess() {
        let (start, end) = makeValidDates()
        let result = service.validate(title: "Test Event", startDate: start, endDate: end)
        XCTAssertEqual(result, .success(()), "Expected success for valid date range")
    }

    // MARK: - Full CalendarEvent Validation

    func testValidate_ValidCalendarEvent_ReturnsSuccess() {
        let (start, end) = makeValidDates()
        let event = CalendarEvent(title: "Appointment", startDate: start, endDate: end)

        let result = service.validate(event)
        XCTAssertEqual(result, .success(()), "Expected success for a valid CalendarEvent")
    }

    func testValidate_CalendarEventWithEmptyTitle_ReturnsFailure() {
        let (start, end) = makeValidDates()
        let event = CalendarEvent(title: "", startDate: start, endDate: end)

        let result = service.validate(event)

        switch result {
        case .failure(let error):
            if case .validationFailed = error {
                // Expected
            } else {
                XCTFail("Expected validationFailed error, got \(error)")
            }
        case .success:
            XCTFail("Expected failure for CalendarEvent with empty title")
        }
    }

    func testValidate_CalendarEventWithInvalidDateRange_ReturnsFailure() {
        let start = Date()
        let end = start.addingTimeInterval(-1800) // end is before start
        let event = CalendarEvent(title: "Bad Event", startDate: start, endDate: end)

        let result = service.validate(event)

        switch result {
        case .failure(let error):
            if case .validationFailed = error {
                // Expected
            } else {
                XCTFail("Expected validationFailed error, got \(error)")
            }
        case .success:
            XCTFail("Expected failure for CalendarEvent with invalid date range")
        }
    }
}
