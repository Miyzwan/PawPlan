import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    
    public init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tampilan & Privasi")) {
                    Toggle("Tampilkan Judul Lengkap", isOn: $viewModel.settings.showFullEventTitle)
                }
                
                Section(header: Text("Apple Watch companion")) {
                    Toggle("Umpan Balik Haptic Watch", isOn: $viewModel.settings.enableWatchHaptic)
                }
                
                Section(header: Text("Informasi")) {
                    HStack {
                        Text("Versi")
                        Spacer()
                        Text("1.0.0 (Fase 0)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Pengaturan")
        }
    }
}
