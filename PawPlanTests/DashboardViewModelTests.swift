import XCTest
import PawPlanShared
@testable import PawPlan

final class MockDateProvider: DateProviderProtocol {
    private let date: Date
    init(date: Date) { self.date = date }
    func currentDate() -> Date { return date }
}

final class DashboardViewModelTests: XCTestCase {
    @MainActor
    func testDashboardInitialState() {
        let mockDate = Date()
        let dateProvider = MockDateProvider(date: mockDate)
        let viewModel = DashboardViewModel(dateProvider: dateProvider)
        
        XCTAssertEqual(viewModel.state, .loading)
    }
    
    @MainActor
    func testDashboardLoadState() async {
        let mockDate = Date()
        let dateProvider = MockDateProvider(date: mockDate)
        let viewModel = DashboardViewModel(dateProvider: dateProvider)
        
        viewModel.loadDashboard()
        
        // Wait for task completion
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        if case .loaded(let data) = viewModel.state {
            XCTAssertEqual(data.petName, "Milo")
            XCTAssertEqual(data.petMood, "Relaxed")
        } else {
            XCTFail("State should be loaded after loadDashboard")
        }
    }
}
