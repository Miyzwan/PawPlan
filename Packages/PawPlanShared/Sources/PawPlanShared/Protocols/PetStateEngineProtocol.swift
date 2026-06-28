import Foundation

public protocol PetStateEngineProtocol {
    /// Awards XP to the pet, triggering level-up when the threshold is reached.
    func awardXP(_ points: Int, to pet: PetProfile) -> PetProfile
    /// Updates the daily streak based on the completion date vs last interaction date.
    func updateStreak(for pet: PetProfile, completionDate: Date) -> PetProfile
    /// Processes a generic pet interaction action.
    func interact(action: PetAction, with pet: PetProfile) -> (PetProfile, String)
    /// Resolves the pet mood based on surrounding calendar events and current time.
    func resolveMood(activeEvent: CalendarEvent?, nextEvent: CalendarEvent?, currentDate: Date) -> PetMood
    /// Feeds the pet (+20 energy, +5 XP).
    func feedPet(_ pet: PetProfile) -> (PetProfile, String)
    /// Plays with the pet (-10 energy, +15 XP).
    func playWithPet(_ pet: PetProfile) -> (PetProfile, String)
}
