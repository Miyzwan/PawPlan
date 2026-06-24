import SwiftUI

public struct AgendaFilterBar: View {
    @Binding var selectedFilter: AgendaFilter
    
    public init(selectedFilter: Binding<AgendaFilter>) {
        self._selectedFilter = selectedFilter
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AgendaFilter.allCases) { filter in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.displayName)
                            .font(AppTypography.captionBold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? AppColorToken.primary : Color.secondary.opacity(0.1))
                            )
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                    }
                    .accessibilityIdentifier("filter_pill_\(filter.rawValue)")
                }
            }
            .padding(.horizontal)
        }
    }
}
