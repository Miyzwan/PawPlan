import Foundation
import UserNotifications
import PawPlanShared

public final class NotificationScheduler: NotificationSchedulerProtocol {
    private let notificationCenter: UserNotificationCenterProtocol
    private let dateProvider: DateProviderProtocol
    private let calendarProvider: CalendarProviderProtocol
    
    public init(
        notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        dateProvider: DateProviderProtocol,
        calendarProvider: CalendarProviderProtocol
    ) {
        self.notificationCenter = notificationCenter
        self.dateProvider = dateProvider
        self.calendarProvider = calendarProvider
    }
    
    public func scheduleReminders(for event: CalendarEvent) async throws {
        // 1. Cancel existing reminders for this event
        try await cancelReminders(for: event)
        
        // 2. Do not schedule if completed, skipped, or cancelled
        guard event.status == .upcoming || event.status == .active else {
            return
        }
        
        // 3. Register custom categories
        registerCategoryAndActions()
        
        let calendar = calendarProvider.currentCalendar()
        let now = dateProvider.now
        
        for offset in event.reminderOffsets {
            let triggerDate = event.startDate.addingTimeInterval(-offset.timeIntervalBefore)
            
            let trigger: UNNotificationTrigger
            if triggerDate > now {
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
                trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            } else if event.startDate > now || (offset == .atTime && event.endDate > now) {
                // If trigger date has just passed but event starts soon or is starting now, trigger in 1 second
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
            } else {
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = event.title
            
            if offset == .atTime {
                content.body = "Agenda '\(event.title)' dimulai sekarang!"
            } else {
                content.body = "Agenda '\(event.title)' dimulai dalam \(formatOffset(offset))."
            }
            
            content.sound = .default
            content.categoryIdentifier = "EVENT_REMINDER"
            content.userInfo = [
                "EVENT_ID": event.id.uuidString,
                "REMINDER_OFFSET": offsetIdentifier(for: offset)
            ]
            
            let identifier = reminderIdentifier(eventId: event.id, offset: offset)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            try await notificationCenter.add(request)
        }
    }
    
    public func cancelReminders(for event: CalendarEvent) async throws {
        // Build identifiers to cancel
        var identifiers = event.reminderOffsets.map { reminderIdentifier(eventId: event.id, offset: $0) }
        
        // Also cancel standard potential offsets just in case the reminder list was updated
        let standardOffsets: [ReminderOffset] = [.atTime, .minutesBefore(5), .minutesBefore(15), .hoursBefore(1), .daysBefore(1)]
        for std in standardOffsets {
            identifiers.append(reminderIdentifier(eventId: event.id, offset: std))
        }
        
        // Remove pending and delivered notifications
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    public func reconcileReminders(with events: [CalendarEvent]) async throws {
        // Clear all pending, then reschedule for all active events
        notificationCenter.removeAllPendingNotificationRequests()
        
        for event in events {
            if event.status == .upcoming || event.status == .active {
                try await scheduleReminders(for: event)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func reminderIdentifier(eventId: UUID, offset: ReminderOffset) -> String {
        return "event.\(eventId.uuidString).reminder.\(offsetIdentifier(for: offset))"
    }
    
    private func offsetIdentifier(for offset: ReminderOffset) -> String {
        switch offset {
        case .atTime: return "atTime"
        case .minutesBefore(let m): return "minutesBefore_\(m)"
        case .hoursBefore(let h): return "hoursBefore_\(h)"
        case .daysBefore(let d): return "daysBefore_\(d)"
        case .custom: return "custom"
        }
    }
    
    private func formatOffset(_ offset: ReminderOffset) -> String {
        switch offset {
        case .atTime: return "sekarang"
        case .minutesBefore(let m): return "\(m) menit"
        case .hoursBefore(let h): return "\(h) jam"
        case .daysBefore(let d): return "\(d) hari"
        case .custom: return "beberapa saat"
        }
    }
    
    private func registerCategoryAndActions() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Selesai",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 10 Menit",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "EVENT_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([category])
    }
}
