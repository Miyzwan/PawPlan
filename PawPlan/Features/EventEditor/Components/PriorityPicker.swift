import SwiftUI
import PawPlanShared

public struct PriorityPicker: View {
    @Binding var selectedPriority: EventPriority
    
    public init(selectedPriority: Binding<EventPriority>) {
        self._selectedPriority = selectedPriority
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prioritas")
                .font(AppTypography.captionBold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                ForEach(EventPriority.allCases, id: \.self) { priority in
                    let isSelected = selectedPriority == priority
                    let color = priorityColor(for: priority)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            selectedPriority = priority
                        }
                    }) {
                        Text(priorityDisplayName(for: priority))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.medium)
                                    .fill(isSelected ? color : Color.secondary.opacity(0.08))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("priority_picker_\(priority.rawValue)")
                }
            }
        }
    }
    
    private func priorityColor(for priority: EventPriority) -> Color {
        switch priority {
        case .low: return .gray
        case .normal: return AppColorToken.primary
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    private func priorityDisplayName(for priority: EventPriority) -> String {
        switch priority {
        case .low: return "Rendah"
        case .normal: return "Normal"
        case .high: return "Tinggi"
        case .urgent: return "Mendesak"
        }
    }
}
