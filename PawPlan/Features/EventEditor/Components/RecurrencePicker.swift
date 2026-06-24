import SwiftUI
import PawPlanShared

public struct RecurrencePicker: View {
    @Binding var selectedRule: RecurrenceRule?
    
    private enum RecurrenceOption: String, CaseIterable, Identifiable {
        case none = "Tidak Ada"
        case daily = "Harian"
        case weekly = "Mingguan"
        case monthly = "Bulanan"
        
        var id: String { self.rawValue }
    }
    
    public init(selectedRule: Binding<RecurrenceRule?>) {
        self._selectedRule = selectedRule
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pengulangan (Recurrence)")
                .font(AppTypography.captionBold)
                .foregroundColor(.secondary)
            
            Picker("Ulangi", selection: Binding(
                get: { currentOption },
                set: { setNewOption($0) }
            )) {
                ForEach(RecurrenceOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var currentOption: RecurrenceOption {
        guard let rule = selectedRule else { return .none }
        switch rule {
        case .none: return .none
        case .daily: return .daily
        case .weekly: return .weekly
        case .monthly: return .monthly
        case .custom: return .none
        }
    }
    
    private func setNewOption(_ option: RecurrenceOption) {
        let calendar = Calendar.current
        let today = Date()
        
        switch option {
        case .none:
            selectedRule = nil
        case .daily:
            selectedRule = .daily
        case .weekly:
            let weekday = calendar.component(.weekday, from: today)
            selectedRule = .weekly(selectedWeekdays: [weekday])
        case .monthly:
            let day = calendar.component(.day, from: today)
            selectedRule = .monthly(dayOfMonth: day)
        }
    }
}
