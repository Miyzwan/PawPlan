import XCTest
@testable import PawPlan

final class RootViewModelTests: XCTestCase {
    @MainActor
    func testActiveTabChanges() {
        let router = AppRouter()
        let viewModel = RootViewModel(router: router)
        
        XCTAssertEqual(viewModel.activeTab, .dashboard)
        
        viewModel.activeTab = .calendar
        XCTAssertEqual(router.activeTab, .calendar)
    }
}
