import SwiftUI
import PawPlanShared

public struct EventTimePicker: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onStartDateChange: (Date) -> Void
    
    public init(
        startDate: Binding<Date>,
        endDate: Binding<Date>,
        onStartDateChange: @escaping (Date) -> Void
    ) {
        self._startDate = startDate
        self._endDate = endDate
        self.onStartDateChange = onStartDateChange
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Start Date Picker
            DatePicker(
                "Mulai",
                selection: Binding(
                    get: { startDate },
                    set: {
                        startDate = $0
                        onStartDateChange($0)
                    }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .font(AppTypography.body)
            .accessibilityIdentifier("picker_start_date")
            
            Divider()
            
            // End Date Picker
            DatePicker(
                "Selesai",
                selection: $endDate,
                in: startDate...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .font(AppTypography.body)
            .accessibilityIdentifier("picker_end_date")
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(AppColorToken.cardBackground)
        .cornerRadius(AppRadius.medium)
    }
}
