import Foundation
import SwiftData
import Combine

@Model
public final class WatchPetSnapshotEntity {
    public var petName: String
    public var speciesRawValue: String
    public var moodRawValue: String
    public var actionRawValue: String
    public var energyLevel: Int
    public var level: Int
    public var experiencePoints: Int
    
    public init(
        petName: String,
        speciesRawValue: String,
        moodRawValue: String,
        actionRawValue: String,
        energyLevel: Int,
        level: Int,
        experiencePoints: Int
    ) {
        self.petName = petName
        self.speciesRawValue = speciesRawValue
        self.moodRawValue = moodRawValue
        self.actionRawValue = actionRawValue
        self.energyLevel = energyLevel
        self.level = level
        self.experiencePoints = experiencePoints
    }
}
