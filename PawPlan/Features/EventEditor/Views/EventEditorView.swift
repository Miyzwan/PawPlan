import SwiftUI
import PawPlanShared

public struct EventEditorView: View {
    @StateObject private var viewModel: EventEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: EventEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Error Message Banner
                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: AppIcon.warning)
                                .foregroundColor(.red)
                            Text(error)
                                .font(AppTypography.captionBold)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(AppRadius.medium)
                        .padding(.horizontal)
                    }
                    
                    // Main Title & Notes Card
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Judul Agenda", text: $viewModel.formState.title)
                            .font(AppTypography.titleMedium)
                            .padding(.vertical, 8)
                            .accessibilityIdentifier("txt_event_title")
                        
                        Divider()
                        
                        TextField("Tambahkan catatan...", text: $viewModel.formState.notes, axis: .vertical)
                            .font(AppTypography.body)
                            .lineLimit(3...6)
                            .accessibilityIdentifier("txt_event_notes")
                    }
                    .padding()
                    .background(AppColorToken.cardBackground)
                    .cornerRadius(AppRadius.large)
                    .padding(.horizontal)
                    
                    // DateTime Picker Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Waktu Pelaksanaan")
                            .font(AppTypography.captionBold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        EventTimePicker(
                            startDate: $viewModel.formState.startDate,
                            endDate: $viewModel.formState.endDate,
                            onStartDateChange: { date in
                                viewModel.updateStartDate(date)
                            }
                        )
                        .padding(.horizontal)
                    }
                    
                    // Category Grid Card
                    CategoryPicker(selectedCategory: $viewModel.formState.category)
                        .padding(.horizontal)
                    
                    // Priority Card
                    PriorityPicker(selectedPriority: $viewModel.formState.priority)
                        .padding(.horizontal)
                    
                    // Reminder Card
                    ReminderPicker(selectedOffsets: $viewModel.formState.reminderOffsets)
                        .padding(.horizontal)
                    
                    // Recurrence Segmented Selector Card
                    RecurrencePicker(selectedRule: $viewModel.formState.recurrenceRule)
                        .padding(.horizontal)
                    
                    // System & Watch Toggles
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pengaturan Tambahan")
                            .font(AppTypography.captionBold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Toggle(isOn: $viewModel.formState.showInDynamicIsland) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tampilkan di Dynamic Island")
                                        .font(AppTypography.bodyBold)
                                    Text("Mendukung Live Activity untuk agenda aktif")
                                        .font(AppTypography.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .tint(AppColorToken.primary)
                            
                            Divider()
                            
                            Toggle(isOn: $viewModel.formState.showOnAppleWatch) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sinkronisasi Apple Watch")
                                        .font(AppTypography.bodyBold)
                                    Text("Tampilkan info agenda pada PawPlan Watch App")
                                        .font(AppTypography.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .tint(AppColorToken.primary)
                        }
                        .padding()
                        .background(AppColorToken.cardBackground)
                        .cornerRadius(AppRadius.medium)
                        .padding(.horizontal)
                    }
                    
                    // Pet Reaction Preset Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reaksi Pet")
                            .font(AppTypography.captionBold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Picker("Reaksi", selection: $viewModel.formState.petReactionPreset) {
                            ForEach(PetReactionPreset.allCases, id: \.self) { preset in
                                Text(presetDisplayName(for: preset)).tag(preset)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColorToken.cardBackground)
                        .cornerRadius(AppRadius.medium)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(AppColorToken.background)
            .navigationTitle(viewModel.isEditMode ? "Ubah Agenda" : "Agenda Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                    .accessibilityIdentifier("btn_cancel_editor")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        viewModel.save()
                    }
                    .font(.body.bold())
                    .foregroundColor(AppColorToken.primary)
                    .accessibilityIdentifier("btn_save_editor")
                }
            }
            .onChange(of: viewModel.isSaved) { saved in
                if saved {
                    dismiss()
                }
            }
        }
    }
    
    private func presetDisplayName(for preset: PetReactionPreset) -> String {
        switch preset {
        case .automatic: return "Otomatis"
        case .calm: return "Tenang"
        case .encouraging: return "Menyemangati"
        case .urgent: return "Mendesak"
        case .playful: return "Ceria"
        case .minimal: return "Minimalis"
        }
    }
}
