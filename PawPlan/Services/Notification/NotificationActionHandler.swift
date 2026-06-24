import Foundation
import UserNotifications
import PawPlanShared

public final class NotificationActionHandler: NSObject, UNUserNotificationCenterDelegate {
    private let eventRepository: EventRepositoryProtocol
    private let dateProvider: DateProviderProtocol
    
    public init(eventRepository: EventRepositoryProtocol, dateProvider: DateProviderProtocol) {
        self.eventRepository = eventRepository
        self.dateProvider = dateProvider
    }
    
    // Intercept notifications in foreground (optional, let them play sound and alert)
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    // Process notification action clicks
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let eventIdString = userInfo["EVENT_ID"] as? String,
              let eventId = UUID(uuidString: eventIdString) else {
            completionHandler()
            return
        }
        
        let actionIdentifier = response.actionIdentifier
        
        Task {
            do {
                if actionIdentifier == "COMPLETE_ACTION" {
                    // Mark the event as completed in database
                    if var event = try await eventRepository.fetchEvent(by: eventId) {
                        event.status = .completed
                        event.completedAt = dateProvider.now
                        event.updatedAt = dateProvider.now
                        try await eventRepository.saveEvent(event)
                    }
                } else if actionIdentifier == "SNOOZE_ACTION" {
                    // Snooze: schedule a new notification in 10 minutes (600 seconds)
                    if let event = try await eventRepository.fetchEvent(by: eventId) {
                        try await snoozeNotification(for: event)
                    }
                }
            } catch {
                // error handling
            }
            completionHandler()
        }
    }
    
    private func snoozeNotification(for event: CalendarEvent) async throws {
        let content = UNMutableNotificationContent()
        content.title = "[Snooze] \(event.title)"
        content.body = "Agenda '\(event.title)' telah ditunda 10 menit."
        content.sound = .default
        content.categoryIdentifier = "EVENT_REMINDER"
        content.userInfo = [
            "EVENT_ID": event.id.uuidString,
            "IS_SNOOZED": true
        ]
        
        // Trigger in 10 minutes (600 seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
        let identifier = "event.\(event.id.uuidString).snooze"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(request)
    }
}
