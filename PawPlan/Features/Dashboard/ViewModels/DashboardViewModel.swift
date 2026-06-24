import Foundation
import Combine
import SwiftUI
import PawPlanShared

public struct DashboardViewData: Equatable {
    public let petName: String
    public let petMood: String
    public let petLevel: Int
    public let todayEventsCount: Int
    
    public init(petName: String, petMood: String, petLevel: Int, todayEventsCount: Int) {
        self.petName = petName
        self.petMood = petMood
        self.petLevel = petLevel
        self.todayEventsCount = todayEventsCount
    }
}

public enum DashboardViewState: Equatable {
    case loading
    case empty
    case loaded(DashboardViewData)
    case error(AppError)
}

@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public private(set) var state: DashboardViewState = .loading
    
    private let dateProvider: DateProviderProtocol
    private var loadTask: Task<Void, Never>?
    
    public init(dateProvider: DateProviderProtocol) {
        self.dateProvider = dateProvider
    }
    
    public func loadDashboard() {
        loadTask?.cancel()
        state = .loading
        
        loadTask = Task {
            // Simulate reading SwiftData in-memory
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s loading
            
            if Task.isCancelled { return }
            
            // Empty state for default setup, or populated sample
            let data = DashboardViewData(
                petName: "Milo",
                petMood: "Relaxed",
                petLevel: 1,
                todayEventsCount: 0
            )
            self.state = .loaded(data)
        }
    }
    
    public func cancelTasks() {
        loadTask?.cancel()
    }
}
