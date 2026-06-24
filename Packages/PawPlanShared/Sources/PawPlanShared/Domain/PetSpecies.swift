import Foundation

public enum PetSpecies: String, Codable, CaseIterable {
    case cat
    case dog
    case bunny
    
    public var displayName: String {
        switch self {
        case .cat: return "Kucing"
        case .dog: return "Anjing"
        case .bunny: return "Kelinci"
        }
    }
}
