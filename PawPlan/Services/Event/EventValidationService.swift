import Foundation
import PawPlanShared

// MARK: - EventValidationService
// Concrete implementation of EventValidationServiceProtocol.
// Delegates business rules to EventValidationRules in PawPlanShared.

public final class EventValidationService: EventValidationServiceProtocol {

    public init() {}

    /// Validates title and date range using shared business rules.
    public func validate(title: String, startDate: Date, endDate: Date) -> Result<Void, AppError> {
        return EventValidationRules.validate(title: title, startDate: startDate, endDate: endDate)
    }

    /// Validates a full CalendarEvent domain model.
    public func validate(_ event: CalendarEvent) -> Result<Void, AppError> {
        return EventValidationRules.validate(
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate
        )
    }
}
