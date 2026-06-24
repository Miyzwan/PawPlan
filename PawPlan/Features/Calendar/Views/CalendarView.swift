import SwiftUI
import PawPlanShared

public struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    
    public init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("🗓️")
                    .font(.system(size: 60))
                Text("Kalender Bulan Ini")
                    .font(AppTypography.titleMedium)
                    .padding(.top, AppSpacing.small)
                Text("Fitur Kalender akan diaktifkan penuh pada Fase 2.")
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Kalender")
            .task {
                viewModel.loadCalendar()
            }
        }
    }
}
