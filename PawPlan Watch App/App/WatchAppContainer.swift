import Foundation
import SwiftData
import PawPlanShared

public final class WatchAppContainer {
    public let modelContainer: ModelContainer
    public let dateProvider: DateProviderProtocol
    
    public init(
        modelContainer: ModelContainer = WatchSwiftDataModelContainer.create(),
        dateProvider: DateProviderProtocol = SystemDateProvider()
    ) {
        self.modelContainer = modelContainer
        self.dateProvider = dateProvider
    }
    
    @MainActor
    public func makeWatchRootViewModel() -> WatchRootViewModel {
        return WatchRootViewModel()
    }
    
    @MainActor
    public func makeWatchNowViewModel() -> WatchNowViewModel {
        return WatchNowViewModel(dateProvider: dateProvider)
    }
    
    @MainActor
    public func makeWatchTodayViewModel() -> WatchTodayViewModel {
        return WatchTodayViewModel()
    }
    
    @MainActor
    public func makeWatchPetViewModel() -> WatchPetViewModel {
        return WatchPetViewModel()
    }
    
    @MainActor
    public func makeWatchSettingsViewModel() -> WatchSettingsViewModel {
        return WatchSettingsViewModel()
    }
}
