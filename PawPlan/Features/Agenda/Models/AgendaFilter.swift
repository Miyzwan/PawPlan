import Foundation

public enum AgendaFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case upcoming
    case completed
    case highPriority
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .all: return "Semua"
        case .today: return "Hari Ini"
        case .upcoming: return "Mendatang"
        case .completed: return "Selesai"
        case .highPriority: return "Prioritas Tinggi"
        }
    }
}
