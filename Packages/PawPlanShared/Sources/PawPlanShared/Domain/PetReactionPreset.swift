import Foundation

public enum PetReactionPreset: String, Codable, CaseIterable {
    case automatic
    case calm
    case encouraging
    case urgent
    case playful
    case minimal
}
