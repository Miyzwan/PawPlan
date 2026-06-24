import SwiftUI
import PawPlanShared

public struct CalendarEventIndicator: View {
    let events: [CalendarEvent]
    
    public init(events: [CalendarEvent]) {
        self.events = events
    }
    
    public var body: some View {
        HStack(spacing: 3) {
            // Get unique category colors from events, limit to 3
            ForEach(Array(uniqueCategoryColors().prefix(3)), id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
            }
        }
    }
    
    private func uniqueCategoryColors() -> [Color] {
        var colors: [Color] = []
        var seenCategories = Set<String>()
        
        for event in events {
            let catRaw = event.category.rawValue
            if !seenCategories.contains(catRaw) {
                seenCategories.insert(catRaw)
                colors.append(AppColorToken.petCategoryColor(for: catRaw))
            }
        }
        
        return colors
    }
}
