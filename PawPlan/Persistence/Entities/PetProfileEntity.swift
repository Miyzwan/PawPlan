import Foundation
import SwiftData
import PawPlanShared

// MARK: - PetProfileEntity
// SwiftData persistence model for PetProfile domain model.
// Stores all pet attributes needed for Fase 4 — Pet Core Experience.

@Model
public final class PetProfileEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var speciesRawValue: String
    public var appearanceVariant: String
    public var currentMoodRawValue: String
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
        speciesRawValue: String,
        appearanceVariant: String = "default",
        currentMoodRawValue: String = PetMood.idle.rawValue,
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
        self.speciesRawValue = speciesRawValue
        self.appearanceVariant = appearanceVariant
        self.currentMoodRawValue = currentMoodRawValue
        self.energyLevel = energyLevel
        self.experiencePoints = experiencePoints
        self.level = level
        self.selectedAccessory = selectedAccessory
        self.lastInteractionDate = lastInteractionDate
        self.streakCount = streakCount
        self.createdAt = createdAt
    }
}

// MARK: - Domain Conversion

extension PetProfileEntity {

    /// Creates an entity from a `PetProfile` domain model.
    convenience init(from profile: PetProfile) {
        self.init(
            id: profile.id,
            name: profile.name,
            speciesRawValue: profile.species.rawValue,
            appearanceVariant: profile.appearanceVariant,
            currentMoodRawValue: profile.currentMood.rawValue,
            energyLevel: profile.energyLevel,
            experiencePoints: profile.experiencePoints,
            level: profile.level,
            selectedAccessory: profile.selectedAccessory,
            lastInteractionDate: profile.lastInteractionDate,
            streakCount: profile.streakCount,
            createdAt: profile.createdAt
        )
    }

    /// Updates the entity's stored properties from an updated `PetProfile` domain model.
    func update(from profile: PetProfile) {
        name = profile.name
        speciesRawValue = profile.species.rawValue
        appearanceVariant = profile.appearanceVariant
        currentMoodRawValue = profile.currentMood.rawValue
        energyLevel = profile.energyLevel
        experiencePoints = profile.experiencePoints
        level = profile.level
        selectedAccessory = profile.selectedAccessory
        lastInteractionDate = profile.lastInteractionDate
        streakCount = profile.streakCount
    }

    /// Converts the entity back to a `PetProfile` domain model.
    func toDomain() -> PetProfile {
        PetProfile(
            id: id,
            name: name,
            species: PetSpecies(rawValue: speciesRawValue) ?? .cat,
            appearanceVariant: appearanceVariant,
            currentMood: PetMood(rawValue: currentMoodRawValue) ?? .idle,
            energyLevel: energyLevel,
            experiencePoints: experiencePoints,
            level: level,
            selectedAccessory: selectedAccessory,
            lastInteractionDate: lastInteractionDate,
            streakCount: streakCount,
            createdAt: createdAt
        )
    }
}
