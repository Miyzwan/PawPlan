import Foundation
import PawPlanShared

public final class SystemDateProvider: DateProviderProtocol {
    public init() {}
    
    public func currentDate() -> Date {
        return Date()
    }
}
