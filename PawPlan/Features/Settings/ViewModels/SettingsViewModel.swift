import Foundation
import Combine
import SwiftUI

@MainActor
public final class SettingsViewModel: ObservableObject {
    @ObservedObject public var settings: AppSettings
    
    public init(settings: AppSettings) {
        self.settings = settings
    }
}
