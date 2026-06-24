import Foundation
import PawPlanShared

// MARK: - EventValidationServiceProtocol
// Abstraction for validating CalendarEvent business rules.
// Use this protocol in ViewModels and tests to enable easy mocking.

public protocol EventValidationServiceProtocol {
    /// Validates a CalendarEvent, returning a result with the validated event or an AppError.
    func validate(title: String, startDate: Date, endDate: Date) -> Result<Void, AppError>

    /// Validates a full CalendarEvent domain model.
    func validate(_ event: CalendarEvent) -> Result<Void, AppError>
}
