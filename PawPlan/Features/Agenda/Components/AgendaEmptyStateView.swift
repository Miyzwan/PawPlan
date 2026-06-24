import SwiftUI

public struct AgendaEmptyStateView: View {
    let filter: AgendaFilter
    
    public init(filter: AgendaFilter) {
        self.filter = filter
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
                .padding()
                .background(
                    Circle()
                        .fill(Color.secondary.opacity(0.05))
                        .frame(width: 100, height: 100)
                )
            
            Text(title)
                .font(AppTypography.titleSmall)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var iconName: String {
        switch filter {
        case .all: return "calendar.badge.plus"
        case .today: return "sparkles"
        case .upcoming: return "calendar"
        case .completed: return "checkmark.seal"
        case .highPriority: return "exclamationmark.triangle"
        }
    }
    
    private var title: String {
        switch filter {
        case .all: return "Belum Ada Agenda"
        case .today: return "Hari Ini Santai"
        case .upcoming: return "Semua Agenda Selesai"
        case .completed: return "Belum Ada Agenda Selesai"
        case .highPriority: return "Bebas dari Prioritas Tinggi"
        }
    }
    
    private var description: String {
        switch filter {
        case .all: return "Mulai buat rencana harianmu dengan menekan tombol tambah di kanan atas."
        case .today: return "Kamu tidak memiliki agenda hari ini. Waktu yang tepat untuk bersantai!"
        case .upcoming: return "Kamu tidak memiliki rencana mendatang untuk saat ini."
        case .completed: return "Selesaikan agenda pertamamu untuk melihatnya di sini!"
        case .highPriority: return "Kerja bagus! Tidak ada agenda prioritas tinggi yang menanti saat ini."
        }
    }
}
