import SwiftUI
import PawPlanShared

public struct EventDetailView: View {
    @StateObject private var viewModel: EventDetailViewModel
    private let container: AppContainer
    
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingEditor = false
    @State private var isShowingDeleteAlert = false
    @State private var duplicateEventToEdit: CalendarEvent? = nil
    
    public init(viewModel: EventDetailViewModel, container: AppContainer) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header status card
                statusHeaderCard
                
                // Primary event details
                VStack(alignment: .leading, spacing: 16) {
                    // Category & Title
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.event.category.sfSymbol)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(AppColorToken.petCategoryColor(for: viewModel.event.category.rawValue))
                            .clipShape(Circle())
                        
                        Text(viewModel.event.category.displayName)
                            .font(AppTypography.captionBold)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        priorityBadge
                    }
                    
                    Text(viewModel.event.title)
                        .font(AppTypography.titleLarge)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Divider()
                    
                    // Time Info Rows
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundColor(AppColorToken.primary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(DateTimeFormatterService.shared.formatFullDate(viewModel.event.startDate))
                                .font(AppTypography.bodyBold)
                            Text("\(DateTimeFormatterService.shared.formatTime(viewModel.event.startDate)) - \(DateTimeFormatterService.shared.formatTime(viewModel.event.endDate))")
                                .font(AppTypography.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Recurrence Rule if exists
                    if let rule = viewModel.event.recurrenceRule, rule != .none {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title3)
                                .foregroundColor(AppColorToken.primary)
                                .frame(width: 24)
                            
                            Text(recurrenceDescription(for: rule))
                                .font(AppTypography.body)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Reminders if exists
                    if !viewModel.event.reminderOffsets.isEmpty {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "bell.fill")
                                .font(.title3)
                                .foregroundColor(AppColorToken.primary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pengingat Aktif:")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(.secondary)
                                
                                ForEach(viewModel.event.reminderOffsets, id: \.timeIntervalBefore) { offset in
                                    Text(reminderOffsetDescription(for: offset))
                                        .font(AppTypography.body)
                                }
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = viewModel.event.notes, !notes.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Catatan")
                                .font(AppTypography.captionBold)
                                .foregroundColor(.secondary)
                            Text(notes)
                                .font(AppTypography.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(AppColorToken.cardBackground)
                .cornerRadius(AppRadius.large)
                .padding(.horizontal)
                
                // Action Buttons Strip
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // Complete/Active Button
                        Button(action: {
                            withAnimation {
                                viewModel.markAsCompleted()
                            }
                        }) {
                            HStack {
                                Image(systemName: viewModel.event.status == .completed ? "arrow.uturn.backward" : "checkmark.circle.fill")
                                Text(viewModel.event.status == .completed ? "Aktifkan Lagi" : "Selesai")
                            }
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.event.status == .completed ? Color.gray : AppColorToken.primary)
                            .cornerRadius(AppRadius.medium)
                        }
                        .accessibilityIdentifier("btn_detail_complete")
                        
                        // Skip Button
                        Button(action: {
                            withAnimation {
                                viewModel.skipEvent()
                            }
                        }) {
                            HStack {
                                Image(systemName: viewModel.event.status == .skipped ? "arrow.uturn.backward" : "forward.fill")
                                Text(viewModel.event.status == .skipped ? "Pulihkan" : "Lewati")
                            }
                            .font(.body.bold())
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(AppRadius.medium)
                        }
                        .accessibilityIdentifier("btn_detail_skip")
                    }
                    
                    HStack(spacing: 12) {
                        // Duplicate Button
                        Button(action: {
                            duplicateEventToEdit = viewModel.makeDuplicateEvent()
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc.fill")
                                Text("Duplikat")
                            }
                            .font(AppTypography.bodyBold)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.secondary.opacity(0.08))
                            .cornerRadius(AppRadius.medium)
                        }
                        .accessibilityIdentifier("btn_detail_duplicate")
                        
                        // Delete Button
                        Button(action: {
                            isShowingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Hapus")
                            }
                            .font(AppTypography.bodyBold)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(AppRadius.medium)
                        }
                        .accessibilityIdentifier("btn_detail_delete")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .background(AppColorToken.background)
        .navigationTitle("Rincian Agenda")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Ubah") {
                    isShowingEditor = true
                }
                .font(.body.bold())
                .foregroundColor(AppColorToken.primary)
                .accessibilityIdentifier("btn_edit_detail")
            }
        }
        .sheet(isPresented: $isShowingEditor, onDismiss: {
            viewModel.reloadEvent()
        }) {
            EventEditorView(viewModel: container.makeEventEditorViewModel(eventToEdit: viewModel.event))
        }
        .sheet(item: $duplicateEventToEdit) { event in
            EventEditorView(viewModel: container.makeEventEditorViewModel(eventToEdit: event))
        }
        .alert("Hapus Agenda", isPresented: $isShowingDeleteAlert) {
            Button("Batal", role: .cancel) {}
            Button("Hapus", role: .destructive) {
                viewModel.deleteEvent()
            }
        } message: {
            Text("Apakah Anda yakin ingin menghapus agenda ini secara permanen?")
        }
        .onChange(of: viewModel.isDeleted) { deleted in
            if deleted {
                dismiss()
            }
        }
    }
    
    // Status Header Card
    private var statusHeaderCard: some View {
        HStack {
            let status = viewModel.event.status
            Image(systemName: statusIcon(for: status))
                .font(.title2)
                .foregroundColor(statusColor(for: status))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle(for: status))
                    .font(AppTypography.bodyBold)
                if status == .completed, let compDate = viewModel.event.completedAt {
                    Text("Diselesaikan pada \(DateTimeFormatterService.shared.formatFullDate(compDate)) \(DateTimeFormatterService.shared.formatTime(compDate))")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(statusDescription(for: status))
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(statusColor(for: viewModel.event.status).opacity(0.08))
        .cornerRadius(AppRadius.large)
        .padding(.horizontal)
    }
    
    // Priority Badge
    private var priorityBadge: some View {
        let priority = viewModel.event.priority
        return Text(priorityLabel(for: priority))
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(priorityColor(for: priority))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor(for: priority).opacity(0.12))
            .cornerRadius(4)
    }
    
    // MARK: - Presenters
    
    private func recurrenceDescription(for rule: RecurrenceRule) -> String {
        switch rule {
        case .none: return "Tidak Berulang"
        case .daily: return "Berulang Setiap Hari"
        case .weekly(let days):
            let weekdayNames = days.map { DateTimeFormatterService.shared.shortWeekdayName(for: $0) }.joined(separator: ", ")
            return "Berulang Setiap Minggu (\(weekdayNames))"
        case .monthly(let day):
            return "Berulang Setiap Bulan (Tanggal \(day))"
        case .custom:
            return "Berulang Kustom"
        }
    }
    
    private func reminderOffsetDescription(for offset: ReminderOffset) -> String {
        switch offset {
        case .atTime: return "Saat acara dimulai"
        case .minutesBefore(let m): return "\(m) menit sebelum"
        case .hoursBefore(let h): return "\(h) jam sebelum"
        case .daysBefore(let d): return "\(d) hari sebelum"
        case .custom: return "Pengingat kustom"
        }
    }
    
    private func priorityLabel(for p: EventPriority) -> String {
        switch p {
        case .low: return "RENDAH"
        case .normal: return "NORMAL"
        case .high: return "TINGGI"
        case .urgent: return "MENDESAK"
        }
    }
    
    private func priorityColor(for p: EventPriority) -> Color {
        switch p {
        case .low: return .gray
        case .normal: return AppColorToken.primary
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    private func statusIcon(for s: EventStatus) -> String {
        switch s {
        case .upcoming: return "calendar.badge.clock"
        case .active: return "play.circle.fill"
        case .completed: return "checkmark.seal.fill"
        case .skipped: return "forward.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    private func statusColor(for s: EventStatus) -> Color {
        switch s {
        case .upcoming: return AppColorToken.primary
        case .active: return .orange
        case .completed: return .green
        case .skipped: return .gray
        case .cancelled: return .red
        }
    }
    
    private func statusTitle(for s: EventStatus) -> String {
        switch s {
        case .upcoming: return "Agenda Mendatang"
        case .active: return "Agenda Aktif"
        case .completed: return "Agenda Selesai"
        case .skipped: return "Agenda Dilewati"
        case .cancelled: return "Agenda Dibatalkan"
        }
    }
    
    private func statusDescription(for s: EventStatus) -> String {
        switch s {
        case .upcoming: return "Rencana terjadwal dan siap dilaksanakan."
        case .active: return "Agenda ini sedang berlangsung sekarang!"
        case .completed: return "Agenda telah berhasil diselesaikan."
        case .skipped: return "Agenda dilewati dan tidak dihitung."
        case .cancelled: return "Agenda telah dibatalkan."
        }
    }
}

// Make CalendarEvent Identifiable for sheet item binding
extension CalendarEvent: Identifiable {
    // Already conforms to Identifiable since `id` is a UUID property
}
