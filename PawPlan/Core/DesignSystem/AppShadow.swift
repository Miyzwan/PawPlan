import SwiftUI
import Combine

public struct AppShadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public static let light = AppShadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    public static let regular = AppShadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
    public static let intense = AppShadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
}

extension View {
    public func appShadow(_ shadow: AppShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
