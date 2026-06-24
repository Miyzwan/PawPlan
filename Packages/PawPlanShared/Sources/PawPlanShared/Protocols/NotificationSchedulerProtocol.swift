import UserNotifications

public protocol NotificationSchedulerProtocol {
    /// Schedules user reminders for the given calendar event based on its reminder offsets.
    func scheduleReminders(for event: CalendarEvent) async throws
    
    /// Cancels all pending reminders scheduled for this calendar event.
    func cancelReminders(for event: CalendarEvent) async throws
    
    /// Re-evaluates and aligns all notifications with the list of current active events.
    func reconcileReminders(with events: [CalendarEvent]) async throws
}

public protocol UserNotificationCenterProtocol {
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>)
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {}
