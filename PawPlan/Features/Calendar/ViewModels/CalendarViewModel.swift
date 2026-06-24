import Foundation
import Combine
import SwiftUI
import PawPlanShared

public enum CalendarViewState: Equatable {
    case loading
    case loaded
}

@MainActor
public final class CalendarViewModel: ObservableObject {
    @Published public private(set) var state: CalendarViewState = .loading
    
    private let dateProvider: DateProviderProtocol
    private let calendarProvider: CalendarProviderProtocol
    
    public init(dateProvider: DateProviderProtocol, calendarProvider: CalendarProviderProtocol) {
        self.dateProvider = dateProvider
        self.calendarProvider = calendarProvider
    }
    
    public func loadCalendar() {
        state = .loaded
    }
}
