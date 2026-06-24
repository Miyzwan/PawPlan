import Foundation

public struct EventPriorityResolver {
    public static func resolveHigherPriority(eventA: CalendarEvent, eventB: CalendarEvent) -> CalendarEvent {
        if eventA.priority > eventB.priority {
            return eventA
        } else if eventA.priority < eventB.priority {
            return eventB
        } else {
            // If priorities are equal, prefer the one starting earlier
            return eventA.startDate <= eventB.startDate ? eventA : eventB
        }
    }
}
