import XCTest
import SwiftData
import PawPlanShared
@testable import PawPlan

// MARK: - DashboardViewModelTests

@MainActor
final class DashboardViewModelTests: XCTestCase {

    private func makeViewModel(events: [CalendarEvent] = []) -> (DashboardViewModel, MockEventRepository) {
        let repo = MockEventRepository()
        repo.stubbedEvents = events
        let vm = DashboardViewModel(
            eventRepository: repo,
            dateProvider: MockDateProvider(),
            calendarProvider: MockCalendarProvider()
        )
        return (vm, repo)
    }

    func testDashboardInitialState() {
        let (viewModel, _) = makeViewModel()
        XCTAssertEqual(viewModel.state, .loading)
    }

    func testDashboardLoadState_WithNoEvents_IsEmpty() async {
        let (viewModel, _) = makeViewModel(events: [])
        viewModel.loadDashboard()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.state, .empty)
    }

    func testDashboardLoadState_WithEvents_IsLoaded() async {
        let start = Date().addingTimeInterval(3600)
        let end = start.addingTimeInterval(3600)
        let event = CalendarEvent(title: "Test Event", startDate: start, endDate: end)

        let (viewModel, _) = makeViewModel(events: [event])
        viewModel.loadDashboard()
        try? await Task.sleep(nanoseconds: 100_000_000)

        if case .loaded(let data) = viewModel.state {
            XCTAssertEqual(data.upcomingEvents.count, 1)
            XCTAssertEqual(data.upcomingEvents.first?.title, "Test Event")
        } else {
            XCTFail("Expected .loaded state, got \(viewModel.state)")
        }
    }

    func testDashboardLoadState_OnRepositoryError_IsError() async {
        let (viewModel, repo) = makeViewModel()
        repo.shouldThrow = true
        viewModel.loadDashboard()
        try? await Task.sleep(nanoseconds: 100_000_000)

        if case .error = viewModel.state {
            // Expected
        } else {
            XCTFail("Expected .error state, got \(viewModel.state)")
        }
    }
}
