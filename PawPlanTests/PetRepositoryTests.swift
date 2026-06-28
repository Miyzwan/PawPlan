import XCTest
import SwiftData
import PawPlanShared
@testable import PawPlan

// MARK: - PetRepositoryTests
// Tests SwiftData-backed persistence of pet profiles using an in-memory container.

final class PetRepositoryTests: XCTestCase {

    var container: ModelContainer!
    var repository: PetRepository!

    override func setUp() async throws {
        try await super.setUp()
        container = SwiftDataModelContainer.create(inMemory: true)
        repository = await PetRepository(modelContainer: container)
    }

    override func tearDown() async throws {
        container = nil
        repository = nil
        try await super.tearDown()
    }

    // MARK: - Tests

    func test_fetchPetProfile_emptyDatabase_returnsDefaultPawPaw() async throws {
        let profile = try await repository.fetchPetProfile()
        XCTAssertNotNil(profile)
        XCTAssertEqual(profile?.name, "PawPaw")
        XCTAssertEqual(profile?.species, .cat)
    }

    func test_savePetProfile_thenFetch_returnsMatchingProfile() async throws {
        let profile = PetProfile(name: "Mochi", species: .dog)
        try await repository.savePetProfile(profile)

        let fetched = try await repository.fetchPetProfile()
        XCTAssertEqual(fetched?.name, "Mochi")
        XCTAssertEqual(fetched?.species, .dog)
    }

    func test_savePetProfile_updateExisting_persistsChanges() async throws {
        var profile = PetProfile(name: "Biscuit", species: .bunny)
        try await repository.savePetProfile(profile)

        profile.name = "Cookie"
        profile.experiencePoints = 50
        try await repository.savePetProfile(profile)

        let fetched = try await repository.fetchPetProfile()
        XCTAssertEqual(fetched?.name, "Cookie")
        XCTAssertEqual(fetched?.experiencePoints, 50)
    }

    func test_savePetProfile_persistsAccessory() async throws {
        var profile = PetProfile(name: "Coco", species: .cat)
        profile.selectedAccessory = "crown"
        try await repository.savePetProfile(profile)

        let fetched = try await repository.fetchPetProfile()
        XCTAssertEqual(fetched?.selectedAccessory, "crown")
    }

    func test_savePetProfile_persistsStreakAndXP() async throws {
        var profile = PetProfile(name: "Luna", species: .dog)
        profile.streakCount = 7
        profile.experiencePoints = 120
        profile.level = 2
        try await repository.savePetProfile(profile)

        let fetched = try await repository.fetchPetProfile()
        XCTAssertEqual(fetched?.streakCount, 7)
        XCTAssertEqual(fetched?.experiencePoints, 120)
        XCTAssertEqual(fetched?.level, 2)
    }
}
