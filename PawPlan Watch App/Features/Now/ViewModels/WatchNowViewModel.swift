import Foundation
import Combine
import SwiftUI
import PawPlanShared

public enum WatchNowViewState: Equatable {
    case loading
    case empty
    case loaded(WatchSyncSnapshot)
    case error(AppError)
}

@MainActor
public final class WatchNowViewModel: ObservableObject {
    @Published public private(set) var state: WatchNowViewState = .loading
    
    private let dateProvider: DateProviderProtocol
    
    public init(dateProvider: DateProviderProtocol) {
        self.dateProvider = dateProvider
    }
    
    public func loadSnapshot() {
        state = .loading
        
        // Setup initial default mock layout for Fase 0
        let mockPet = WatchPetSnapshot(
            petName: "Milo",
            species: .cat,
            mood: .idle,
            action: .idle,
            energyLevel: 100,
            level: 1,
            experiencePoints: 10
        )
        
        let snapshot = WatchSyncSnapshot(
            sourceDeviceIdentifier: "Simulator",
            pet: mockPet
        )
        
        state = .loaded(snapshot)
    }
}
