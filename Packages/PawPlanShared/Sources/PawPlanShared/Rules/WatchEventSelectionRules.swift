import Foundation

public struct WatchEventSelectionRules {
    public static func selectActiveAndNextEvents(
        from events: [CalendarEvent],
        currentDate: Date,
        calendar: Calendar
    ) -> (active: CalendarEvent?, next: CalendarEvent?, today: [CalendarEvent]) {
        let todayEvents = events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: currentDate) ||
            calendar.isDate(event.endDate, inSameDayAs: currentDate) ||
            (event.startDate < currentDate && event.endDate > currentDate)
        }
        
        let active = todayEvents.first { event in
            event.startDate <= currentDate && event.endDate >= currentDate && event.status == .upcoming
        }
        
        let next = todayEvents
            .filter { event in event.startDate > currentDate && event.status == .upcoming }
            .min(by: { $0.startDate < $1.startDate })
            
        return (active, next, todayEvents)
    }
}
