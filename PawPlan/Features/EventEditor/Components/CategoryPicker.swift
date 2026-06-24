import SwiftUI
import PawPlanShared

public struct CategoryPicker: View {
    @Binding var selectedCategory: EventCategory
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public init(selectedCategory: Binding<EventCategory>) {
        self._selectedCategory = selectedCategory
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kategori")
                .font(AppTypography.captionBold)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(EventCategory.allCases, id: \.self) { category in
                    let isSelected = selectedCategory == category
                    let color = AppColorToken.petCategoryColor(for: category.rawValue)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                            selectedCategory = category
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: category.sfSymbol)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(isSelected ? .white : color)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(isSelected ? color : color.opacity(0.12))
                                )
                            
                            Text(category.displayName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(isSelected ? .primary : .secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.medium)
                                .fill(isSelected ? AppColorToken.cardBackground : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.medium)
                                        .stroke(isSelected ? color.opacity(0.3) : Color.clear, lineWidth: 1.5)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("cat_picker_\(category.rawValue)")
                }
            }
        }
    }
}
