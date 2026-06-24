import Foundation

public enum PetAction: String, Codable, CaseIterable {
    case idle
    case walkLeft
    case walkRight
    case jump
    case teleport
    case blink
    case wave
    case focus
    case celebrate
    case sleep
}
