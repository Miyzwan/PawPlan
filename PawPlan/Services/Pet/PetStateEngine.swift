import Foundation
import PawPlanShared

// MARK: - PetStateEngine
// Concrete implementation of PetStateEngineProtocol.
// Handles XP/level progression, daily streak tracking, mood resolution,
// and all interactive pet actions (feed, play, teleport, etc.).

public final class PetStateEngine: PetStateEngineProtocol {

    // MARK: - Constants

    private enum Config {
        static let xpPerLevel = 100
        static let feedEnergyGain = 20
        static let feedXPGain = 5
        static let playEnergyLoss = 10
        static let playXPGain = 15
        static let eventCompleteXPGain = 20
        static let maxEnergy = 100
        static let minEnergy = 0
    }

    // MARK: - Init

    public init() {}

    // MARK: - XP & Level

    public func awardXP(_ points: Int, to pet: PetProfile) -> PetProfile {
        var updated = pet
        updated.experiencePoints += points
        // Level up for every 100 XP accumulated
        let newLevel = max(1, updated.experiencePoints / Config.xpPerLevel + 1)
        if newLevel > updated.level {
            updated.level = newLevel
        }
        return updated
    }

    // MARK: - Streak

    public func updateStreak(for pet: PetProfile, completionDate: Date) -> PetProfile {
        var updated = pet
        let calendar = Calendar.current

        if let lastDate = pet.lastInteractionDate {
            let daysDiff = calendar.dateComponents([.day], from: lastDate, to: completionDate).day ?? 0
            if daysDiff == 1 {
                // Consecutive day — continue streak
                updated.streakCount += 1
            } else if daysDiff == 0 {
                // Same day — keep streak unchanged
            } else {
                // Streak broken
                updated.streakCount = 1
            }
        } else {
            // First interaction ever
            updated.streakCount = 1
        }

        updated.lastInteractionDate = completionDate
        return updated
    }

    // MARK: - Mood Resolution

    public func resolveMood(
        activeEvent: CalendarEvent?,
        nextEvent: CalendarEvent?,
        currentDate: Date
    ) -> PetMood {
        PetStateRules.resolveMood(
            activeEvent: activeEvent,
            nextEvent: nextEvent,
            currentDate: currentDate
        )
    }

    // MARK: - Pet Interactions

    public func feedPet(_ pet: PetProfile) -> (PetProfile, String) {
        var updated = pet
        updated.energyLevel = min(Config.maxEnergy, updated.energyLevel + Config.feedEnergyGain)
        updated = awardXP(Config.feedXPGain, to: updated)
        updated.lastInteractionDate = Date()

        let dialogues = [
            "Nyam nyam! Enak banget! 😋",
            "Makasih makanannya~ 🍕",
            "Aku kenyang! Siap bertugas! 💪",
            "Yummy! Ini favoritku! ✨"
        ]
        return (updated, dialogues.randomElement()!)
    }

    public func playWithPet(_ pet: PetProfile) -> (PetProfile, String) {
        var updated = pet
        let newEnergy = updated.energyLevel - Config.playEnergyLoss
        updated.energyLevel = max(Config.minEnergy, newEnergy)
        updated = awardXP(Config.playXPGain, to: updated)
        updated.lastInteractionDate = Date()
        updated.currentMood = .excited

        let dialogues: [String]
        if newEnergy < Config.playEnergyLoss {
            dialogues = [
                "Capek... tapi senang! 😪",
                "Istirahat dulu ya... 💤",
                "Mainnya besok lagi ya~ 😴"
            ]
        } else {
            dialogues = [
                "Horeee main bareng! 🎉",
                "Lagi semangat nih! 🌟",
                "Asyik banget bermain denganmu! 🐾",
                "Lagi! Lagi! Lagi! 😸"
            ]
        }
        return (updated, dialogues.randomElement()!)
    }

    public func interact(action: PetAction, with pet: PetProfile) -> (PetProfile, String) {
        var updated = pet
        updated.lastInteractionDate = Date()

        switch action {
        case .teleport:
            let dialogues = [
                "Hiii! Ketahuan deh! 👀",
                "Cari aku di mana? 😼",
                "Bim salabim! ✨",
                "Kamu ngagetin aku! 😹"
            ]
            return (updated, dialogues.randomElement()!)

        case .wave:
            updated.currentMood = .happy
            return (updated, "Haii! Ada apa nih? 👋")

        case .celebrate:
            updated.currentMood = .excited
            updated = awardXP(5, to: updated)
            return (updated, "Yeay! Kita rayakan! 🎊")

        case .jump:
            return (updated, "Weeee! 🦘")

        case .blink:
            return (updated, "Zzz... eh? Ada kamu! 😳")

        case .sleep:
            updated.currentMood = .sleeping
            return (updated, "Zzzzz... 💤")

        case .focus:
            updated.currentMood = .focused
            return (updated, "Ssst, lagi konsentrasi! 🧠")

        default:
            return (updated, "Halo! 🐾")
        }
    }
}
