import XCTest
import PawPlanShared
@testable import PawPlan

// MARK: - PetStateEngineTests
// Tests the core XP/level progression, daily streak logic, mood resolution,
// energy clamping for interactions, and dialogue output.

final class PetStateEngineTests: XCTestCase {

    var engine: PetStateEngine!
    var basePet: PetProfile!

    override func setUp() {
        super.setUp()
        engine = PetStateEngine()
        basePet = PetProfile(name: "TestPaw", species: .cat)
    }

    // MARK: - XP & Level

    func test_awardXP_increasesXP() {
        let result = engine.awardXP(30, to: basePet)
        XCTAssertEqual(result.experiencePoints, 30)
    }

    func test_awardXP_levelUpAt100XP() {
        var pet = basePet!
        pet.experiencePoints = 90
        pet.level = 1
        let result = engine.awardXP(10, to: pet)
        XCTAssertEqual(result.experiencePoints, 100)
        XCTAssertEqual(result.level, 2)
    }

    func test_awardXP_multiLevelJump() {
        var pet = basePet!
        pet.experiencePoints = 0
        let result = engine.awardXP(250, to: pet)
        XCTAssertEqual(result.level, 3)
    }

    func test_awardXP_noLevelDowngrade() {
        var pet = basePet!
        pet.level = 5
        pet.experiencePoints = 400
        let result = engine.awardXP(10, to: pet)
        XCTAssertGreaterThanOrEqual(result.level, 5)
    }

    // MARK: - Streak

    func test_updateStreak_firstInteraction_setsStreak1() {
        let result = engine.updateStreak(for: basePet, completionDate: Date())
        XCTAssertEqual(result.streakCount, 1)
    }

    func test_updateStreak_consecutiveDay_incrementsStreak() {
        var pet = basePet!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        pet.lastInteractionDate = yesterday
        pet.streakCount = 3
        let result = engine.updateStreak(for: pet, completionDate: Date())
        XCTAssertEqual(result.streakCount, 4)
    }

    func test_updateStreak_sameDay_keepsStreak() {
        var pet = basePet!
        pet.lastInteractionDate = Date()
        pet.streakCount = 5
        let result = engine.updateStreak(for: pet, completionDate: Date())
        XCTAssertEqual(result.streakCount, 5)
    }

    func test_updateStreak_twoOrMoreDaysMissed_resetsStreak() {
        var pet = basePet!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        pet.lastInteractionDate = twoDaysAgo
        pet.streakCount = 10
        let result = engine.updateStreak(for: pet, completionDate: Date())
        XCTAssertEqual(result.streakCount, 1)
    }

    // MARK: - Feed

    func test_feedPet_increasesEnergy() {
        var pet = basePet!
        pet.energyLevel = 60
        let (result, _) = engine.feedPet(pet)
        XCTAssertEqual(result.energyLevel, 80)
    }

    func test_feedPet_clampedAt100() {
        var pet = basePet!
        pet.energyLevel = 95
        let (result, _) = engine.feedPet(pet)
        XCTAssertEqual(result.energyLevel, 100)
    }

    func test_feedPet_awardsXP() {
        let (result, _) = engine.feedPet(basePet)
        XCTAssertEqual(result.experiencePoints, 5)
    }

    func test_feedPet_returnsNonEmptyDialogue() {
        let (_, dialogue) = engine.feedPet(basePet)
        XCTAssertFalse(dialogue.isEmpty)
    }

    // MARK: - Play

    func test_playWithPet_decreasesEnergy() {
        var pet = basePet!
        pet.energyLevel = 50
        let (result, _) = engine.playWithPet(pet)
        XCTAssertEqual(result.energyLevel, 40)
    }

    func test_playWithPet_clampedAtZero() {
        var pet = basePet!
        pet.energyLevel = 5
        let (result, _) = engine.playWithPet(pet)
        XCTAssertEqual(result.energyLevel, 0)
    }

    func test_playWithPet_awardsXP() {
        let (result, _) = engine.playWithPet(basePet)
        XCTAssertEqual(result.experiencePoints, 15)
    }

    func test_playWithPet_setsMoodExcited() {
        let (result, _) = engine.playWithPet(basePet)
        XCTAssertEqual(result.currentMood, .excited)
    }

    // MARK: - Mood Resolution

    func test_resolveMood_noEvents_returnsSleeping() {
        let mood = engine.resolveMood(activeEvent: nil, nextEvent: nil, currentDate: Date())
        XCTAssertEqual(mood, .sleeping)
    }

    func test_resolveMood_activeEvent_returnsFocused() {
        let now = Date()
        let active = makeEvent(start: now.addingTimeInterval(-60), end: now.addingTimeInterval(3600))
        let mood = engine.resolveMood(activeEvent: active, nextEvent: nil, currentDate: now)
        XCTAssertEqual(mood, .focused)
    }

    func test_resolveMood_completedActiveEvent_returnsHappy() {
        let now = Date()
        var active = makeEvent(start: now.addingTimeInterval(-60), end: now.addingTimeInterval(3600))
        active.status = .completed
        let mood = engine.resolveMood(activeEvent: active, nextEvent: nil, currentDate: now)
        XCTAssertEqual(mood, .happy)
    }

    func test_resolveMood_within15Min_returnsAlert() {
        let now = Date()
        let next = makeEvent(start: now.addingTimeInterval(600), end: now.addingTimeInterval(3600))
        let mood = engine.resolveMood(activeEvent: nil, nextEvent: next, currentDate: now)
        XCTAssertEqual(mood, .alert)
    }

    func test_resolveMood_overdue_returnsConcerned() {
        let now = Date()
        let next = makeEvent(start: now.addingTimeInterval(-3600), end: now.addingTimeInterval(-1800))
        let mood = engine.resolveMood(activeEvent: nil, nextEvent: next, currentDate: now)
        XCTAssertEqual(mood, .concerned)
    }

    // MARK: - Helpers

    private func makeEvent(start: Date, end: Date) -> CalendarEvent {
        CalendarEvent(
            title: "Test Event",
            startDate: start,
            endDate: end,
            status: .upcoming
        )
    }
}
