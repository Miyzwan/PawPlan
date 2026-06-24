import SwiftUI
import PawPlanShared

public struct ReminderPicker: View {
    @Binding var selectedOffsets: [ReminderOffset]
    
    private let options: [(label: String, offset: ReminderOffset)] = [
        ("Saat acara mulai", .atTime),
        ("5 menit sebelum", .minutesBefore(5)),
        ("15 menit sebelum", .minutesBefore(15)),
        ("1 jam sebelum", .hoursBefore(1)),
        ("1 hari sebelum", .daysBefore(1))
    ]
    
    public init(selectedOffsets: Binding<[ReminderOffset]>) {
        self._selectedOffsets = selectedOffsets
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pengingat (Reminders)")
                .font(AppTypography.captionBold)
                .foregroundColor(.secondary)
            
            VStack(spacing: 0) {
                ForEach(0..<options.count, id: \.self) { index in
                    let option = options[index]
                    let isSelected = hasOffset(option.offset)
                    
                    HStack {
                        Text(option.label)
                            .font(AppTypography.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColorToken.primary)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background(isSelected ? AppColorToken.primary.opacity(0.08) : Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleOffset(option.offset)
                    }
                    .accessibilityIdentifier("reminder_picker_item_\(index)")
                    
                    if index < options.count - 1 {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
            .background(AppColorToken.cardBackground)
            .cornerRadius(AppRadius.medium)
        }
    }
    
    private func hasOffset(_ offset: ReminderOffset) -> Bool {
        return selectedOffsets.contains(offset)
    }
    
    private func toggleOffset(_ offset: ReminderOffset) {
        var current = selectedOffsets
        if let idx = current.firstIndex(of: offset) {
            current.remove(at: idx)
        } else {
            current.append(offset)
        }
        selectedOffsets = current
    }
}
