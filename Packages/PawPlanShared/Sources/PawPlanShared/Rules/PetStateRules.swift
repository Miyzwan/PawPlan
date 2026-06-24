import Foundation

public struct PetStateRules {
    public static func resolveMood(
        activeEvent: CalendarEvent?,
        nextEvent: CalendarEvent?,
        currentDate: Date
    ) -> PetMood {
        if let active = activeEvent {
            if active.status == .completed {
                return .happy
            }
            return .focused
        }
        
        guard let next = nextEvent else {
            return .sleeping
        }
        
        let timeToNext = next.startDate.timeIntervalSince(currentDate)
        
        if timeToNext < 0 {
            // Overdue
            return .concerned
        } else if timeToNext <= 15 * 60 {
            // Within 15 minutes
            return .alert
        } else if timeToNext <= 60 * 60 {
            // Within 60 minutes
            return .alert
        } else if timeToNext <= 24 * 3600 {
            return .idle
        } else {
            return .relaxed
        }
    }
}
