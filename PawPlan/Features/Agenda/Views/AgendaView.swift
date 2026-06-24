import SwiftUI
import PawPlanShared

public struct AgendaView: View {
    @StateObject private var viewModel: AgendaViewModel
    private let container: AppContainer
    
    public init(viewModel: AgendaViewModel, container: AppContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Filter Selector
            AgendaFilterBar(selectedFilter: $viewModel.selectedFilter)
                .padding(.top, 4)
            
            // Content
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .frame(maxHeight: .infinity)
                case .empty:
                    AgendaEmptyStateView(filter: viewModel.selectedFilter)
                case .loaded(let groups):
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                            ForEach(groups) { group in
                                Section(header: sectionHeader(for: group.date)) {
                                    VStack(spacing: 8) {
                                        ForEach(group.events) { event in
                                            NavigationLink(destination: EventDetailView(viewModel: container.makeEventDetailViewModel(event: event), container: container)) {
                                                AgendaEventRow(event: event) {
                                                    viewModel.toggleEventCompletion(event)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                case .error(let error):
                    VStack(spacing: 8) {
                        Image(systemName: AppIcon.warning)
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Terjadi Kesalahan")
                            .font(AppTypography.titleSmall)
                        Text(error.localizedDescription)
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            viewModel.loadEvents()
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
    
    private func sectionHeader(for date: Date) -> some View {
        Text(DateTimeFormatterService.shared.formatFullDate(date))
            .font(AppTypography.captionBold)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColorToken.background)
    }
}
