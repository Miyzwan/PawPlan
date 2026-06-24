import Foundation

public struct WatchPetSnapshot: Codable, Equatable {
    public let petName: String
    public let species: PetSpecies
    public let mood: PetMood
    public let action: PetAction
    public let energyLevel: Int
    public let level: Int
    public let experiencePoints: Int
    public var selectedAccessory: String?
    
    public init(
        petName: String,
        species: PetSpecies,
        mood: PetMood,
        action: PetAction,
        energyLevel: Int,
        level: Int,
        experiencePoints: Int,
        selectedAccessory: String? = nil
    ) {
        self.petName = petName
        self.species = species
        self.mood = mood
        self.action = action
        self.energyLevel = energyLevel
        self.level = level
        self.experiencePoints = experiencePoints
        self.selectedAccessory = selectedAccessory
    }
}
