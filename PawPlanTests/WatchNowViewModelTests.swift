import XCTest
import PawPlanShared
@testable import PawPlan

final class WatchNowViewModelTests: XCTestCase {
    @MainActor
    func testWatchNowInitialState() {
        let mockDate = Date()
        let dateProvider = MockDateProvider(date: mockDate)
        let viewModel = WatchNowViewModel(dateProvider: dateProvider)
        
        XCTAssertEqual(viewModel.state, .loading)
    }
    
    @MainActor
    func testWatchNowLoadSnapshot() {
        let mockDate = Date()
        let dateProvider = MockDateProvider(date: mockDate)
        let viewModel = WatchNowViewModel(dateProvider: dateProvider)
        
        viewModel.loadSnapshot()
        
        if case .loaded(let snapshot) = viewModel.state {
            XCTAssertEqual(snapshot.pet.petName, "Milo")
            XCTAssertEqual(snapshot.pet.mood, .idle)
        } else {
            XCTFail("State should be loaded after loadSnapshot")
        }
    }
}
