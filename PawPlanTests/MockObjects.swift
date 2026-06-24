import Foundation
import PawPlanShared
@testable import PawPlan

final class MockDateProvider: DateProviderProtocol {
    var mockDate: Date
    
    init(date: Date = Date()) {
        self.mockDate = date
    }
    
    func currentDate() -> Date {
        return mockDate
    }
}

final class MockCalendarProvider: CalendarProviderProtocol {
    var mockCalendar: Calendar = Calendar.current
    
    func currentCalendar() -> Calendar {
        return mockCalendar
    }
}

final class MockEventRepository: EventRepositoryProtocol {
    var stubbedEvents: [CalendarEvent] = []
    var shouldThrow = false
    
    func fetchEvents() async throws -> [CalendarEvent] {
        if shouldThrow {
            throw AppError.databaseError("Mock DB Error")
        }
        return stubbedEvents
    }
    
    func fetchEvent(by id: UUID) async throws -> CalendarEvent? {
        if shouldThrow {
            throw AppError.databaseError("Mock DB Error")
        }
        return stubbedEvents.first { $0.id == id }
    }
    
    func saveEvent(_ event: CalendarEvent) async throws {
        if shouldThrow {
            throw AppError.databaseError("Mock DB Error")
        }
        if let index = stubbedEvents.firstIndex(where: { $0.id == event.id }) {
            stubbedEvents[index] = event
        } else {
            stubbedEvents.append(event)
        }
    }
    
    func deleteEvent(by id: UUID) async throws {
        if shouldThrow {
            throw AppError.databaseError("Mock DB Error")
        }
        stubbedEvents.removeAll { $0.id == id }
    }
}

final class MockEventValidationService: EventValidationServiceProtocol {
    var stubbedResult: Result<Void, AppError> = .success(())
    
    func validate(title: String, startDate: Date, endDate: Date) -> Result<Void, AppError> {
        return stubbedResult
    }
    
    func validate(_ event: CalendarEvent) -> Result<Void, AppError> {
        return stubbedResult
    }
}

import UserNotifications

final class MockUserNotificationCenter: UserNotificationCenterProtocol {
    var addedRequests: [UNNotificationRequest] = []
    var pendingIdentifiersToRemove: [[String]] = []
    var deliveredIdentifiersToRemove: [[String]] = []
    var allPendingRemovedCount = 0
    var stubbedCategories: Set<UNNotificationCategory> = []
    var shouldThrow = false
    
    func add(_ request: UNNotificationRequest) async throws {
        if shouldThrow {
            throw NSError(domain: "MockUNNotificationCenterError", code: 1, userInfo: nil)
        }
        addedRequests.append(request)
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        pendingIdentifiersToRemove.append(identifiers)
        addedRequests.removeAll { identifiers.contains($0.identifier) }
    }
    
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        deliveredIdentifiersToRemove.append(identifiers)
    }
    
    func removeAllPendingNotificationRequests() {
        allPendingRemovedCount += 1
        addedRequests.removeAll()
    }
    
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
        stubbedCategories = categories
    }
}
