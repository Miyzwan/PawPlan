import XCTest
import PawPlanShared
@testable import PawPlan

@MainActor
final class EventEditorViewModelTests: XCTestCase {
    
    private var dateProvider: MockDateProvider!
    private var eventRepository: MockEventRepository!
    private var validationService: MockEventValidationService!
    private var viewModel: EventEditorViewModel!
    private var mockDate: Date!
    
    override func setUp() {
        super.setUp()
        mockDate = Date()
        dateProvider = MockDateProvider(date: mockDate)
        eventRepository = MockEventRepository()
        validationService = MockEventValidationService()
        
        viewModel = EventEditorViewModel(
            eventRepository: eventRepository,
            validationService: validationService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        validationService = nil
        eventRepository = nil
        dateProvider = nil
        super.tearDown()
    }
    
    func testInitialState_CreateMode() {
        XCTAssertNil(viewModel.eventToEdit)
        XCTAssertFalse(viewModel.isEditMode)
        XCTAssertEqual(viewModel.formState.title, "")
        XCTAssertEqual(viewModel.formState.category, .other)
        XCTAssertEqual(viewModel.formState.priority, .normal)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isSaved)
    }
    
    func testInitialState_EditMode() {
        let existingEvent = CalendarEvent(
            id: UUID(),
            title: "Existing Title",
            notes: "Some notes",
            startDate: mockDate,
            endDate: mockDate.addingTimeInterval(3600),
            category: .work,
            priority: .high
        )
        
        viewModel = EventEditorViewModel(
            eventRepository: eventRepository,
            validationService: validationService,
            eventToEdit: existingEvent
        )
        
        XCTAssertEqual(viewModel.eventToEdit, existingEvent)
        XCTAssertTrue(viewModel.isEditMode)
        XCTAssertEqual(viewModel.formState.title, "Existing Title")
        XCTAssertEqual(viewModel.formState.notes, "Some notes")
        XCTAssertEqual(viewModel.formState.category, .work)
        XCTAssertEqual(viewModel.formState.priority, .high)
    }
    
    func testUpdateStartDateAdjustsEndDate() {
        let start = mockDate!
        let end = start.addingTimeInterval(1800) // 30 minutes later
        viewModel.formState.startDate = start
        viewModel.formState.endDate = end
        
        // Setting start to a time after end should auto-shift end to start + 1 hour
        let newStart = start.addingTimeInterval(3600) // 1 hour later (same as end)
        viewModel.updateStartDate(newStart)
        
        XCTAssertEqual(viewModel.formState.startDate, newStart)
        XCTAssertEqual(viewModel.formState.endDate, newStart.addingTimeInterval(3600))
    }
    
    func testSave_WithValidationError_DoesNotSave() async {
        validationService.stubbedResult = .failure(.validationError("Title cannot be empty"))
        viewModel.formState.title = ""
        
        viewModel.save()
        try? await Task.sleep(nanoseconds: 20_000_000)
        
        XCTAssertEqual(viewModel.errorMessage, "Title cannot be empty")
        XCTAssertFalse(viewModel.isSaved)
        XCTAssertTrue(eventRepository.stubbedEvents.isEmpty)
    }
    
    func testSave_WithValidFields_SavesToRepository() async {
        viewModel.formState.title = "Valid Title"
        viewModel.formState.startDate = mockDate
        viewModel.formState.endDate = mockDate.addingTimeInterval(3600)
        viewModel.formState.category = .personal
        
        viewModel.save()
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.isSaved)
        XCTAssertEqual(eventRepository.stubbedEvents.count, 1)
        XCTAssertEqual(eventRepository.stubbedEvents.first?.title, "Valid Title")
        XCTAssertEqual(eventRepository.stubbedEvents.first?.category, .personal)
    }
}
