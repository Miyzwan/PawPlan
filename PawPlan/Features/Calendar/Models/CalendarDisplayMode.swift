import Foundation

public enum CalendarDisplayMode: String, CaseIterable, Identifiable {
    case calendar
    case agenda
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .calendar: return "Kalender"
        case .agenda: return "Agenda"
        }
    }
}
