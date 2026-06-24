import XCTest
@testable import PawPlanShared

final class PawPlanSharedTests: XCTestCase {
    func testEventValidationRules() {
        let now = Date()
        let result = EventValidationRules.validate(title: "", startDate: now, endDate: now.addingTimeInterval(3600))
        XCTAssertEqual(result, .failure(.validationFailed("Judul event tidak boleh kosong.")))
        
        let result2 = EventValidationRules.validate(title: "Rapat", startDate: now, endDate: now)
        XCTAssertEqual(result2, .failure(.validationFailed("Waktu selesai harus setelah waktu mulai.")))
        
        let result3 = EventValidationRules.validate(title: "Rapat", startDate: now, endDate: now.addingTimeInterval(3600))
        XCTAssertEqual(result3, .success(()))
    }
    
    func testPetStateRules() {
        let now = Date()
        let mood = PetStateRules.resolveMood(activeEvent: nil, nextEvent: nil, currentDate: now)
        XCTAssertEqual(mood, .sleeping)
    }
}
