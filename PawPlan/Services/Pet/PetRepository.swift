import Foundation
import SwiftData
import PawPlanShared

// MARK: - PetRepository
// Concrete implementation of PetRepositoryProtocol using SwiftData.
// Always works with a single pet profile. Auto-seeds a default "PawPaw" cat
// if the database has no pet yet.

@MainActor
public final class PetRepository: PetRepositoryProtocol {

    // MARK: - Dependencies

    private let modelContainer: ModelContainer

    private var context: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Init

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - PetRepositoryProtocol

    public func fetchPetProfile() async throws -> PetProfile? {
        let descriptor = FetchDescriptor<PetProfileEntity>()
        let entities = try context.fetch(descriptor)
        if let entity = entities.first {
            return entity.toDomain()
        }
        // Auto-seed a default pet so the UI is never empty on first launch
        let defaultPet = PetProfile(name: "PawPaw", species: .cat)
        try await savePetProfile(defaultPet)
        return defaultPet
    }

    public func savePetProfile(_ profile: PetProfile) async throws {
        let id = profile.id
        let predicate = #Predicate<PetProfileEntity> { $0.id == id }
        var descriptor = FetchDescriptor<PetProfileEntity>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            existing.update(from: profile)
        } else {
            let entity = PetProfileEntity(from: profile)
            context.insert(entity)
        }

        try context.save()
    }
}
