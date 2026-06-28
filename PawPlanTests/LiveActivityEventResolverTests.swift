import XCTest
import PawPlanShared
@testable import PawPlan

final class LiveActivityEventResolverTests: XCTestCase {

    var resolver: LiveActivityEventResolver!
    var petProfile: PetProfile!

    override func setUp() {
        super.setUp()
        resolver = LiveActivityEventResolver()
        petProfile = PetProfile(name: "PawPaw", species: .cat)
    }

    override func tearDown() {
        resolver = nil
        petProfile = nil
        super.tearDown()
    }

    // MARK: - Tests: shouldShowLiveActivity

    func testShouldShowLiveActivity_upcomingWithin3Hours_returnsTrue() {
        let now = Date()
        let event = makeEvent(
            start: now.addingTimeInterval(3600), // 1 hour from now
            end: now.addingTimeInterval(7200),
            showInDynamicIsland: true
        )
        XCTAssertTrue(resolver.shouldShowLiveActivity(for: event))
    }

    func testShouldShowLiveActivity_upcomingMoreThan3Hours_returnsFalse() {
        let now = Date()
        let event = makeEvent(
            start: now.addingTimeInterval(4 * 3600), // 4 hours from now
            end: now.addingTimeInterval(5 * 3600),
            showInDynamicIsland: true
        )
        XCTAssertFalse(resolver.shouldShowLiveActivity(for: event))
    }

    func testShouldShowLiveActivity_inProgress_returnsTrue() {
        let now = Date()
        let event = makeEvent(
            start: now.addingTimeInterval(-1800), // started 30 mins ago
            end: now.addingTimeInterval(1800),   // ends in 30 mins
            showInDynamicIsland: true
        )
        XCTAssertTrue(resolver.shouldShowLiveActivity(for: event))
    }

    func testShouldShowLiveActivity_completed_returnsFalse() {
        let now = Date()
        var event = makeEvent(
            start: now.addingTimeInterval(3600),
            end: now.addingTimeInterval(7200),
            showInDynamicIsland: true
        )
        event.status = .completed
        XCTAssertFalse(resolver.shouldShowLiveActivity(for: event))
    }

    func testShouldShowLiveActivity_disabledInDynamicIsland_returnsFalse() {
        let now = Date()
        let event = makeEvent(
            start: now.addingTimeInterval(3600),
            end: now.addingTimeInterval(7200),
            showInDynamicIsland: false
        )
        XCTAssertFalse(resolver.shouldShowLiveActivity(for: event))
    }

    // MARK: - Tests: resolveEvent

    func testResolveEvent_selectsActiveOverSoonest() {
        let now = Date()
        let soonest = makeEvent(
            start: now.addingTimeInterval(1800), // 30 mins from now
            end: now.addingTimeInterval(3600),
            showInDynamicIsland: true
        )
        let active = makeEvent(
            start: now.addingTimeInterval(-1800), // in progress
            end: now.addingTimeInterval(3600),
            showInDynamicIsland: true
        )

        let events = [soonest, active]
        let resolved = resolver.resolveEvent(from: events)
        XCTAssertEqual(resolved?.id, active.id, "Expected in-progress event to take priority")
    }

    func testResolveEvent_selectsSoonestUpcomingWhenNoActive() {
        let now = Date()
        let far = makeEvent(
            start: now.addingTimeInterval(7200), // 2 hours from now
            end: now.addingTimeInterval(9000),
            showInDynamicIsland: true
        )
        let soon = makeEvent(
            start: now.addingTimeInterval(3600), // 1 hour from now
            end: now.addingTimeInterval(5400),
            showInDynamicIsland: true
        )

        let events = [far, soon]
        let resolved = resolver.resolveEvent(from: events)
        XCTAssertEqual(resolved?.id, soon.id, "Expected soonest upcoming event to be resolved")
    }

    // MARK: - Tests: Dialogue

    func testDialogueForContext_completed() {
        var event = makeEvent(start: Date(), end: Date().addingTimeInterval(3600), showInDynamicIsland: true)
        event.status = .completed
        let dialogue = resolver.dialogueForContext(event: event, pet: petProfile)
        XCTAssertTrue(dialogue.contains("selesai"), "Dialogue: '\(dialogue)' should mention completion")
    }

    func testDialogueForContext_ongoing() {
        let now = Date()
        let event = makeEvent(start: now.addingTimeInterval(-1800), end: now.addingTimeInterval(1800), showInDynamicIsland: true)
        let dialogue = resolver.dialogueForContext(event: event, pet: petProfile)
        XCTAssertTrue(dialogue.contains("fokus menemanimu"), "Dialogue: '\(dialogue)' should mention focusing")
    }

    func testDialogueForContext_upcomingUnder15Mins() {
        let now = Date()
        let event = makeEvent(start: now.addingTimeInterval(600), end: now.addingTimeInterval(3600), showInDynamicIsland: true)
        let dialogue = resolver.dialogueForContext(event: event, pet: petProfile)
        XCTAssertTrue(dialogue.contains("Waspada"), "Dialogue: '\(dialogue)' should show alert warning")
    }

    // MARK: - Helpers

    private func makeEvent(
        start: Date,
        end: Date,
        showInDynamicIsland: Bool
    ) -> CalendarEvent {
        CalendarEvent(
            title: "Test Event",
            startDate: start,
            endDate: end,
            showInDynamicIsland: showInDynamicIsland
        )
    }
}
