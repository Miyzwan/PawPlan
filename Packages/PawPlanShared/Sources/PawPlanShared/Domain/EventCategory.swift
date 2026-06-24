import Foundation

public enum EventCategory: String, Codable, CaseIterable {
    case school
    case work
    case meeting
    case health
    case personal
    case finance
    case family
    case travel
    case other
    
    public var displayName: String {
        switch self {
        case .school: return "Sekolah"
        case .work: return "Pekerjaan"
        case .meeting: return "Rapat"
        case .health: return "Kesehatan"
        case .personal: return "Pribadi"
        case .finance: return "Keuangan"
        case .family: return "Keluarga"
        case .travel: return "Perjalanan"
        case .other: return "Lainnya"
        }
    }
    
    public var sfSymbol: String {
        switch self {
        case .school: return "book.fill"
        case .work: return "briefcase.fill"
        case .meeting: return "person.3.sequence.fill"
        case .health: return "heart.text.square.fill"
        case .personal: return "person.fill"
        case .finance: return "dollarsign.circle.fill"
        case .family: return "house.fill"
        case .travel: return "airplane"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    public var defaultPetAccessory: String? {
        switch self {
        case .school: return "glasses"
        case .work: return "tie"
        case .travel: return "hat"
        default: return nil
        }
    }
}
