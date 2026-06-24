import SwiftUI
import PawPlanShared

public struct CalendarDayCell: View {
    let day: CalendarDayViewData
    let onTap: () -> Void
    
    public init(day: CalendarDayViewData, onTap: @escaping () -> Void) {
        self.day = day
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(day.dayNumber)
                    .font(day.isSelected || day.isToday ? AppTypography.bodyBold : AppTypography.body)
                    .foregroundColor(textColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(backgroundColor)
                    )
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: day.isToday ? 2 : 0)
                    )
                
                CalendarEventIndicator(events: day.events)
                    .frame(height: 6)
            }
        }
        .opacity(day.isCurrentMonth ? 1.0 : 0.4)
        .accessibilityIdentifier("day_cell_\(day.dayNumber)")
    }
    
    private var textColor: Color {
        if day.isSelected {
            return .white
        } else if day.isToday {
            return AppColorToken.primary
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if day.isSelected {
            return AppColorToken.primary
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        if day.isToday && !day.isSelected {
            return AppColorToken.primary.opacity(0.6)
        } else {
            return .clear
        }
    }
}
