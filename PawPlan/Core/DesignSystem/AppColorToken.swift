import SwiftUI

public enum AppColorToken {
    // Premium theme colors (Harmonious tones using system fallbacks and custom RGB)
    public static let primary = Color(red: 0.12, green: 0.63, blue: 0.59) // Beautiful Premium Teal
    public static let secondary = Color(red: 0.08, green: 0.45, blue: 0.42) // Darker Teal
    public static let background = Color(uiColor: .systemGroupedBackground) // Auto light/dark background
    public static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground) // Auto light/dark card background
    
    // Fallback colors for default views before assets catalog is set up
    public static let mint = Color.mint
    public static let teal = Color.teal
    public static let slate = Color(red: 0.09, green: 0.11, blue: 0.15)
    public static let offWhite = Color(red: 0.97, green: 0.97, blue: 0.98)
    
    public static func petCategoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "school": return .blue
        case "work": return .indigo
        case "meeting": return .orange
        case "health": return .red
        case "personal": return .purple
        case "finance": return .green
        case "family": return .pink
        case "travel": return .teal
        default: return .gray
        }
    }
}
