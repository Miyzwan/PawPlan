import SwiftUI

public enum AppTypography {
    public static let titleLarge = Font.system(.title, design: .rounded).weight(.bold)
    public static let titleMedium = Font.system(.title2, design: .rounded).weight(.semibold)
    public static let titleSmall = Font.system(.title3, design: .rounded).weight(.medium)
    public static let body = Font.system(.body, design: .default)
    public static let bodyBold = Font.system(.body, design: .default).weight(.semibold)
    public static let caption = Font.system(.caption, design: .default)
    public static let captionBold = Font.system(.caption, design: .default).weight(.medium)
}
