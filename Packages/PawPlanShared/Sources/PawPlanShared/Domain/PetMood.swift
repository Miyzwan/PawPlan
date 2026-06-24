import Foundation

public enum PetMood: String, Codable, CaseIterable {
    case sleeping
    case relaxed
    case idle
    case alert
    case focused
    case excited
    case happy
    case concerned
    
    public var displayName: String {
        switch self {
        case .sleeping: return "Tidur"
        case .relaxed: return "Santai"
        case .idle: return "Diam"
        case .alert: return "Waspada"
        case .focused: return "Fokus"
        case .excited: return "Bersemangat"
        case .happy: return "Senang"
        case .concerned: return "Khawatir"
        }
    }
}
