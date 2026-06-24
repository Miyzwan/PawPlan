import Foundation

public protocol EventRepositoryProtocol {
    func fetchEvents() async throws -> [CalendarEvent]
    func fetchEvent(by id: UUID) async throws -> CalendarEvent?
    func saveEvent(_ event: CalendarEvent) async throws
    func deleteEvent(by id: UUID) async throws
}
