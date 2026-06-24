import SwiftUI
import PawPlanShared

public struct MonthlyCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    public init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Month & Navigation Header
            HStack {
                Text(DateTimeFormatterService.shared.formatMonthYear(viewModel.visibleDate))
                    .font(AppTypography.titleSmall)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation {
                            viewModel.previousMonth()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColorToken.primary)
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("btn_prev_month")
                    
                    Button(action: {
                        withAnimation {
                            viewModel.nextMonth()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColorToken.primary)
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("btn_next_month")
                }
            }
            .padding(.horizontal)
            
            // Weekday symbols
            HStack(spacing: 0) {
                ForEach(orderedWeekdays(), id: \.self) { weekday in
                    Text(DateTimeFormatterService.shared.shortWeekdayName(for: weekday))
                        .font(AppTypography.captionBold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
            
            // Days Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.days) { day in
                    CalendarDayCell(day: day) {
                        viewModel.selectDate(day.date)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.large)
                .fill(AppColorToken.cardBackground.opacity(0.4))
        )
    }
    
    /// Returns the 1-indexed weekday numbers in the order they should appear based on calendar's firstWeekday settings
    private func orderedWeekdays() -> [Int] {
        let calendar = Calendar.current
        let first = calendar.firstWeekday
        return (0..<7).map { (first + $0 - 1) % 7 + 1 }
    }
}
