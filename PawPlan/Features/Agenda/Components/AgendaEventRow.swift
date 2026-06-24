import SwiftUI
import PawPlanShared

public struct AgendaEventRow: View {
    let event: CalendarEvent
    let onToggleComplete: () -> Void
    
    public init(event: CalendarEvent, onToggleComplete: @escaping () -> Void) {
        self.event = event
        self.onToggleComplete = onToggleComplete
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Priority Accent Line
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
                .cornerRadius(2)
                .frame(maxHeight: .infinity)
            
            // Completion Toggle Checkbox
            Button(action: onToggleComplete) {
                Image(systemName: event.status == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(event.status == .completed ? AppColorToken.primary : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityIdentifier("btn_complete_\(event.id.uuidString)")
            
            // Event Details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(AppTypography.bodyBold)
                    .strikethrough(event.status == .completed)
                    .foregroundColor(event.status == .completed ? .secondary : .primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: event.category.sfSymbol)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColorToken.petCategoryColor(for: event.category.rawValue))
                    
                    Text(event.category.displayName)
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    Text(DateTimeFormatterService.shared.formatTimeRange(start: event.startDate, end: event.endDate))
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Priority/Status Indicators
            if event.priority == .urgent {
                Text("URGENT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
            } else if event.status == .skipped {
                Text("Dilewati")
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.medium)
                .fill(AppColorToken.cardBackground)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
    }
    
    private var priorityColor: Color {
        switch event.priority {
        case .urgent: return .red
        case .high: return .orange
        case .normal: return AppColorToken.primary
        case .low: return .gray
        }
    }
}
