import Foundation

public protocol PetRepositoryProtocol {
    /// Returns the single pet profile, or nil if none exists yet.
    func fetchPetProfile() async throws -> PetProfile?
    /// Persists (insert or update) the pet profile.
    func savePetProfile(_ profile: PetProfile) async throws
}
