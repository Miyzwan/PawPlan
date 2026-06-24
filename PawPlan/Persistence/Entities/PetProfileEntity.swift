import Foundation
import SwiftData
import Combine

@Model
public final class PetProfileEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var speciesRawValue: String
    public var energyLevel: Int
    public var experiencePoints: Int
    public var level: Int
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        speciesRawValue: String,
        energyLevel: Int = 100,
        experiencePoints: Int = 0,
        level: Int = 1,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.speciesRawValue = speciesRawValue
        self.energyLevel = energyLevel
        self.experiencePoints = experiencePoints
        self.level = level
        self.createdAt = createdAt
    }
}
