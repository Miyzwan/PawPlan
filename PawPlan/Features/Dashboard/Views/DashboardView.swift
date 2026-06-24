import SwiftUI
import PawPlanShared

public struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    
    public init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.large) {
                    switch viewModel.state {
                    case .loading:
                        ProgressView("Memuat data...")
                            .accessibilityIdentifier("dashboard_loading_indicator")
                    case .empty:
                        VStack(spacing: AppSpacing.medium) {
                            Text("🐾")
                                .font(.system(size: 80))
                            Text("Belum ada jadwal hari ini")
                                .font(AppTypography.titleMedium)
                                .foregroundColor(.secondary)
                        }
                    case .loaded(let data):
                        VStack(spacing: AppSpacing.medium) {
                            // Pet visual card
                            VStack(spacing: AppSpacing.small) {
                                Text("🐶")
                                    .font(.system(size: 100))
                                    .padding(.top, AppSpacing.medium)
                                    .scaleEffect(1.0)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: data.petName)
                                
                                Text(data.petName)
                                    .font(AppTypography.titleMedium)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("Mood: \(data.petMood)")
                                    Spacer()
                                    Text("Level \(data.petLevel)")
                                }
                                .font(AppTypography.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, AppSpacing.medium)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(AppRadius.medium)
                            .appShadow(.light)
                            .padding(.horizontal, AppSpacing.medium)
                            
                            // Event summaries card
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text("Jadwal Hari Ini")
                                    .font(AppTypography.titleSmall)
                                    .foregroundColor(.primary)
                                
                                Text("Semua agenda selesai! Pet Anda sangat senang.")
                                    .font(AppTypography.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(AppRadius.medium)
                            .appShadow(.light)
                            .padding(.horizontal, AppSpacing.medium)
                            
                            Spacer()
                        }
                        .accessibilityIdentifier("dashboard_loaded_content")
                    case .error(let error):
                        VStack(spacing: AppSpacing.medium) {
                            Image(systemName: AppIcon.warning)
                                .foregroundColor(.red)
                                .font(.largeTitle)
                            Text(error.localizedDescription)
                                .font(AppTypography.body)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
                .navigationTitle("Dashboard")
                .task {
                    viewModel.loadDashboard()
                }
                .onDisappear {
                    viewModel.cancelTasks()
                }
            }
        }
    }
}
