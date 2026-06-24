import Foundation

public struct PetProfile: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var species: PetSpecies
    public var appearanceVariant: String
    public var currentMood: PetMood
    public var energyLevel: Int
    public var experiencePoints: Int
    public var level: Int
    public var selectedAccessory: String?
    public var lastInteractionDate: Date?
    public var streakCount: Int
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        species: PetSpecies,
        appearanceVariant: String = "default",
        currentMood: PetMood = .idle,
        energyLevel: Int = 100,
        experiencePoints: Int = 0,
        level: Int = 1,
        selectedAccessory: String? = nil,
        lastInteractionDate: Date? = nil,
        streakCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.appearanceVariant = appearanceVariant
        self.currentMood = currentMood
        self.energyLevel = energyLevel
        self.experiencePoints = experiencePoints
        self.level = level
        self.selectedAccessory = selectedAccessory
        self.lastInteractionDate = lastInteractionDate
        self.streakCount = streakCount
        self.createdAt = createdAt
    }
}
