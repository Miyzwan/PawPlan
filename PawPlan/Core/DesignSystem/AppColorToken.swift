import SwiftUI

public enum AppColorToken {
    // Premium theme colors (Harmonious tones)
    public static let primary = Color("PrimaryColor", bundle: .main)
    public static let secondary = Color("SecondaryColor", bundle: .main)
    public static let background = Color("BackgroundColor", bundle: .main)
    public static let cardBackground = Color("CardBackgroundColor", bundle: .main)
    
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
