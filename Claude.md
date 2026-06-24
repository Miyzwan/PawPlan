Bertindaklah sebagai Lead iOS Engineer, SwiftUI Architect, dan Product Engineer untuk membangun aplikasi iOS native bernama sementara:

“PawPlan” / “Pet Calendar”

Aplikasi ini adalah personal calendar dan scheduler dengan virtual pet sebagai asisten visual. Pet bereaksi terhadap agenda pengguna, memberi konteks visual untuk jadwal terdekat, dan muncul secara kontekstual melalui Dynamic Island serta Live Activity.

Jangan membangun seluruh aplikasi sekaligus. Implementasikan aplikasi berdasarkan fase pengembangan yang ditentukan. Setiap fase harus menghasilkan project yang bisa di-build, dijalankan, diuji, dan dikembangkan ke fase berikutnya.

Gunakan Bahasa Indonesia untuk penjelasan teknis kepada developer, tetapi gunakan Bahasa Inggris untuk nama file, class, struct, enum, protocol, variable, function, dan komentar kode.

==================================================

1. PRODUCT OVERVIEW
   ==================================================

Buat aplikasi kalender dan personal planner dengan virtual pet sebagai pendamping produktivitas.

Fungsi utama aplikasi:

* Pengguna dapat membuat, melihat, mengubah, menghapus, dan menyelesaikan event kalender.
* Pengguna dapat mengatur reminder untuk setiap event.
* Pengguna dapat melihat agenda harian, mingguan, bulanan, dan daftar event mendatang.
* Virtual pet bereaksi terhadap status jadwal pengguna.
* Pet muncul di dashboard aplikasi dan dapat berinteraksi melalui tap.
* Dynamic Island dan Live Activity digunakan untuk menampilkan status event penting atau event yang sedang berlangsung.
* Local notification tetap menjadi sistem reminder utama.
* Dynamic Island adalah pelengkap visual dan akses cepat, bukan satu-satunya sistem reminder.
* Aplikasi harus tetap berfungsi penuh pada perangkat tanpa Dynamic Island.

Target pengguna:

* Pelajar.
* Mahasiswa.
* Pekerja.
* Pengguna personal productivity app.
* Pengguna iPhone yang menyukai gamification ringan.

Gaya produk:

* Clean.
* Calm.
* Cute tetapi tidak terlalu kekanak-kanakan.
* Produktif.
* Mudah dibaca.
* Fokus pada kalender dan reminder.
* Pet harus terasa hidup tanpa mengganggu fokus.

==================================================
2. PRODUCT PRINCIPLES
=====================

1. Calendar dan reminder adalah fitur inti.
2. Pet adalah lapisan pengalaman visual, bukan fitur utama yang mengorbankan usability kalender.
3. Semua event harus tetap bisa diakses tanpa Dynamic Island.
4. Semua event harus tetap bisa diingatkan dengan local notification.
5. Jangan membuat aplikasi bergantung pada background execution untuk pet.
6. Jangan membuat pet berjalan bebas secara real-time di Dynamic Island.
7. Dynamic Island hanya menampilkan state pet ringan seperti:

   * idle
   * relaxed
   * alert
   * focused
   * happy
   * sleeping
8. Hanya satu Live Activity utama yang aktif untuk aplikasi ini.
9. Event yang sedang berlangsung lebih prioritas daripada event mendatang.
10. Event urgent lebih prioritas daripada event normal.
11. Permission hanya diminta ketika pengguna membutuhkan fiturnya.
12. MVP harus berjalan sepenuhnya secara lokal tanpa backend, login, atau cloud sync.
13. Semua business logic harus testable.
14. Semua View harus ringan dan tidak berisi business logic.

==================================================
3. PLATFORM DAN TECH STACK
==========================

Platform minimum:

* iOS 17.0+
* Swift 5.9+
* SwiftUI
* SwiftData
* WidgetKit
* ActivityKit
* UserNotifications
* EventKit untuk fase integrasi Apple Calendar
* AppIntents untuk quick action bila diperlukan
* OSLog untuk logging
* Swift Concurrency menggunakan async/await

Jangan gunakan dependency pihak ketiga pada MVP kecuali benar-benar diperlukan.

Jangan gunakan:

* Firebase.
* Supabase.
* Backend.
* Login system.
* Analytics pihak ketiga.
* Force unwrap.
* Massive singleton.
* View yang langsung mengakses persistence layer.
* ViewModel yang langsung mengakses SwiftData ModelContext.

==================================================
4. ARCHITECTURE — FEATURE-FIRST MVVM
====================================

Gunakan arsitektur Feature-First MVVM.

Prinsip MVVM:

* View bertanggung jawab untuk rendering UI dan menerima input pengguna.
* ViewModel bertanggung jawab untuk presentation logic, state UI, validasi ringan, dan pemanggilan service/use case.
* Model domain tidak boleh bergantung pada SwiftUI, WidgetKit, atau ActivityKit.
* Service menangani business logic, persistence, notification, Live Activity, dan calendar integration.
* ViewModel harus mengakses dependency melalui protocol.
* Dependency injection harus menggunakan AppContainer atau DependencyContainer.
* Semua ViewModel harus mudah diuji menggunakan mock dependency.
* Semua ViewModel harus menggunakan @MainActor bila mengelola UI state.
* Jangan menyimpan SwiftUI View di dalam ViewModel.
* Jangan meletakkan warna, font, atau layout UI di ViewModel.
* Jangan memanggil Date() langsung dalam business logic. Gunakan DateProvider.
* Jangan akses ModelContext langsung dari View atau ViewModel.

==================================================
5. PROJECT DIRECTORY
====================

Gunakan struktur folder berikut:

PetCalendarApp/
├── App/
│   ├── PetCalendarApp.swift
│   ├── AppContainer.swift
│   ├── RootView.swift
│   ├── RootViewModel.swift
│   ├── AppRouter.swift
│   └── AppSettings.swift
│
├── Core/
│   ├── DesignSystem/
│   │   ├── AppColorToken.swift
│   │   ├── AppTypography.swift
│   │   ├── AppSpacing.swift
│   │   ├── AppRadius.swift
│   │   ├── AppIcon.swift
│   │   └── AppShadow.swift
│   │
│   ├── DateTime/
│   │   ├── DateProviderProtocol.swift
│   │   ├── SystemDateProvider.swift
│   │   ├── CalendarProviderProtocol.swift
│   │   ├── SystemCalendarProvider.swift
│   │   └── DateTimeFormatterService.swift
│   │
│   ├── Logging/
│   │   └── AppLogger.swift
│   │
│   ├── Localization/
│   │   └── LocalizationKey.swift
│   │
│   ├── Extensions/
│   ├── Utilities/
│   ├── Errors/
│   │   └── AppError.swift
│   │
│   └── DependencyInjection/
│       └── DependencyContainer.swift
│
├── Models/
│   ├── Domain/
│   │   ├── CalendarEvent.swift
│   │   ├── EventCategory.swift
│   │   ├── EventPriority.swift
│   │   ├── EventStatus.swift
│   │   ├── ReminderOffset.swift
│   │   ├── RecurrenceRule.swift
│   │   ├── EventSource.swift
│   │   ├── PetProfile.swift
│   │   ├── PetSpecies.swift
│   │   ├── PetMood.swift
│   │   ├── PetAction.swift
│   │   └── PetReactionPreset.swift
│   │
│   ├── Persistence/
│   │   ├── CalendarEventEntity.swift
│   │   ├── PetProfileEntity.swift
│   │   └── SwiftDataModelContainer.swift
│   │
│   └── DTO/
│       └── ExternalCalendarEventDTO.swift
│
├── Services/
│   ├── Event/
│   │   ├── EventRepositoryProtocol.swift
│   │   ├── EventRepository.swift
│   │   ├── EventValidationService.swift
│   │   ├── EventOccurrenceService.swift
│   │   ├── EventPriorityResolver.swift
│   │   └── EventQueryService.swift
│   │
│   ├── Notification/
│   │   ├── NotificationSchedulerProtocol.swift
│   │   ├── NotificationScheduler.swift
│   │   ├── NotificationPermissionManager.swift
│   │   └── NotificationActionHandler.swift
│   │
│   ├── Pet/
│   │   ├── PetStateEngineProtocol.swift
│   │   ├── PetStateEngine.swift
│   │   ├── PetAnimationResolver.swift
│   │   └── PetRewardService.swift
│   │
│   ├── LiveActivity/
│   │   ├── LiveActivityManagerProtocol.swift
│   │   ├── LiveActivityManager.swift
│   │   ├── LiveActivityEventResolver.swift
│   │   └── PetLiveActivityAttributes.swift
│   │
│   └── CalendarIntegration/
│       ├── CalendarSyncServiceProtocol.swift
│       ├── CalendarSyncService.swift
│       └── EventKitPermissionManager.swift
│
├── Features/
│   ├── Onboarding/
│   │   ├── Views/
│   │   │   ├── OnboardingView.swift
│   │   │   └── PermissionExplanationView.swift
│   │   ├── ViewModels/
│   │   │   └── OnboardingViewModel.swift
│   │   └── Components/
│   │
│   ├── Dashboard/
│   │   ├── Views/
│   │   │   └── DashboardView.swift
│   │   ├── ViewModels/
│   │   │   └── DashboardViewModel.swift
│   │   ├── Components/
│   │   │   ├── NextEventCard.swift
│   │   │   ├── UpcomingEventList.swift
│   │   │   ├── DashboardEmptyStateView.swift
│   │   │   └── DailySummaryCard.swift
│   │   └── Models/
│   │       ├── DashboardViewState.swift
│   │       └── DashboardViewData.swift
│   │
│   ├── Calendar/
│   │   ├── Views/
│   │   │   ├── CalendarView.swift
│   │   │   ├── MonthlyCalendarView.swift
│   │   │   ├── WeeklyCalendarView.swift
│   │   │   └── DailyCalendarView.swift
│   │   ├── ViewModels/
│   │   │   ├── CalendarViewModel.swift
│   │   │   ├── MonthlyCalendarViewModel.swift
│   │   │   └── DailyCalendarViewModel.swift
│   │   ├── Components/
│   │   │   ├── CalendarDayCell.swift
│   │   │   ├── CalendarEventIndicator.swift
│   │   │   └── CalendarToolbar.swift
│   │   └── Models/
│   │       ├── CalendarDisplayMode.swift
│   │       └── CalendarDayViewData.swift
│   │
│   ├── Agenda/
│   │   ├── Views/
│   │   │   └── AgendaView.swift
│   │   ├── ViewModels/
│   │   │   └── AgendaViewModel.swift
│   │   ├── Components/
│   │   │   ├── AgendaEventRow.swift
│   │   │   ├── AgendaFilterBar.swift
│   │   │   └── AgendaEmptyStateView.swift
│   │   └── Models/
│   │       └── AgendaFilter.swift
│   │
│   ├── EventEditor/
│   │   ├── Views/
│   │   │   ├── EventEditorView.swift
│   │   │   └── EventDetailView.swift
│   │   ├── ViewModels/
│   │   │   ├── EventEditorViewModel.swift
│   │   │   └── EventDetailViewModel.swift
│   │   ├── Components/
│   │   │   ├── EventTimePicker.swift
│   │   │   ├── ReminderPicker.swift
│   │   │   ├── RecurrencePicker.swift
│   │   │   ├── CategoryPicker.swift
│   │   │   └── PriorityPicker.swift
│   │   └── Models/
│   │       └── EventEditorFormState.swift
│   │
│   ├── Pet/
│   │   ├── Views/
│   │   │   ├── PetView.swift
│   │   │   ├── PetProfileView.swift
│   │   │   └── PetQuickActionsView.swift
│   │   ├── ViewModels/
│   │   │   ├── PetViewModel.swift
│   │   │   └── PetProfileViewModel.swift
│   │   ├── Components/
│   │   │   ├── PetSpriteView.swift
│   │   │   ├── PetMoodBadge.swift
│   │   │   └── PetExperienceBar.swift
│   │   └── Models/
│   │       └── PetViewState.swift
│   │
│   ├── LiveActivity/
│   │   ├── Views/
│   │   │   └── LiveActivityControlView.swift
│   │   ├── ViewModels/
│   │   │   └── LiveActivityControlViewModel.swift
│   │   └── Models/
│   │       └── LiveActivityViewState.swift
│   │
│   └── Settings/
│       ├── Views/
│       │   └── SettingsView.swift
│       ├── ViewModels/
│       │   └── SettingsViewModel.swift
│       ├── Components/
│       │   ├── NotificationSettingsSection.swift
│       │   ├── CalendarSyncSettingsSection.swift
│       │   └── PetCustomizationSection.swift
│       └── Models/
│           └── SettingsViewState.swift
│
├── Widgets/
│   ├── PetCalendarWidgetBundle.swift
│   ├── NextEventWidget.swift
│   ├── PetLiveActivity.swift
│   ├── PetLiveActivityDynamicIsland.swift
│   └── WidgetSharedDataProvider.swift
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.xcstrings
│   └── PreviewContent/
│
└── Tests/
├── Mocks/
│   ├── MockEventRepository.swift
│   ├── MockNotificationScheduler.swift
│   ├── MockLiveActivityManager.swift
│   ├── MockDateProvider.swift
│   └── MockCalendarProvider.swift
│
├── UnitTests/
│   ├── Models/
│   ├── Services/
│   ├── ViewModels/
│   └── Features/
│
├── IntegrationTests/
│   ├── EventPersistenceTests.swift
│   ├── NotificationSchedulingTests.swift
│   └── LiveActivityWorkflowTests.swift
│
└── UITests/
├── DashboardUITests.swift
├── CalendarUITests.swift
├── EventEditorUITests.swift
└── PetInteractionUITests.swift

==================================================
6. NAMING CONVENTION
====================

Gunakan pola nama berikut:

View:

* [Feature]View.swift

ViewModel:

* [Feature]ViewModel.swift

View state:

* [Feature]ViewState.swift

View data:

* [Feature]ViewData.swift

Component:

* [Purpose]View.swift
* [Purpose]Card.swift
* [Purpose]Row.swift

Service:

* [Responsibility]Service.swift

Protocol:

* [Responsibility]Protocol.swift

Contoh:

* DashboardView
* DashboardViewModel
* DashboardViewState
* DashboardViewData
* EventEditorView
* EventEditorViewModel
* EventValidationService
* NotificationSchedulerProtocol

==================================================
7. DOMAIN MODELS
================

A. CalendarEvent

Properties:

* id: UUID
* title: String
* notes: String?
* startDate: Date
* endDate: Date
* timeZoneIdentifier: String
* category: EventCategory
* priority: EventPriority
* status: EventStatus
* reminderOffsets: [ReminderOffset]
* recurrenceRule: RecurrenceRule?
* showInDynamicIsland: Bool
* petReactionPreset: PetReactionPreset
* createdAt: Date
* updatedAt: Date
* completedAt: Date?
* source: EventSource
* externalCalendarEventIdentifier: String?

Rules:

* Title tidak boleh kosong setelah whitespace dihapus.
* endDate harus lebih besar dari startDate.
* Event dapat memiliki nol atau lebih reminder.
* Event dapat ditandai selesai sebelum endDate.
* Event yang dihapus harus membatalkan notification terkait.
* Event yang diedit harus menjadwalkan ulang notification terkait.
* Simpan tanggal secara konsisten dan tampilkan sesuai timezone perangkat atau timezone event.

B. EventCategory

Cases:

* school
* work
* meeting
* health
* personal
* finance
* family
* travel
* other

Setiap category harus memiliki:

* displayName
* SF Symbol
* visual token
* default pet accessory optional

C. EventPriority

Cases:

* low
* normal
* high
* urgent

D. EventStatus

Cases:

* upcoming
* active
* completed
* skipped
* cancelled

E. ReminderOffset

Cases:

* atTime
* minutesBefore(Int)
* hoursBefore(Int)
* daysBefore(Int)
* custom(DateComponents)

F. RecurrenceRule

MVP recurrence:

* none
* daily
* weekly(selectedWeekdays)
* monthly(dayOfMonth)
* custom(interval, frequency, endDate?)

Jangan membuat recurrence engine yang terlalu kompleks pada fase awal. Buat fondasi yang mudah dikembangkan.

G. PetProfile

Properties:

* id: UUID
* name: String
* species: PetSpecies
* appearanceVariant: String
* currentMood: PetMood
* energyLevel: Int
* experiencePoints: Int
* level: Int
* selectedAccessory: String?
* lastInteractionDate: Date?
* streakCount: Int
* createdAt: Date

H. PetMood

Cases:

* sleeping
* relaxed
* idle
* alert
* focused
* excited
* happy
* concerned

I. PetAction

Cases:

* idle
* walkLeft
* walkRight
* jump
* teleport
* blink
* wave
* focus
* celebrate
* sleep

J. PetReactionPreset

Cases:

* automatic
* calm
* encouraging
* urgent
* playful
* minimal

==================================================
8. VIEWMODEL RULES
==================

Setiap ViewModel harus:

* Menggunakan @MainActor bila mengelola UI state.
* Memiliki state eksplisit untuk loading, empty, loaded, dan error.
* Mengakses data melalui protocol service atau repository.
* Tidak mengakses SwiftData ModelContext secara langsung.
* Tidak menyimpan View SwiftUI.
* Tidak memiliki layout atau style hardcoded.
* Tidak memanggil Date() secara langsung.
* Menangani cancellation untuk Task asynchronous.
* Memiliki fungsi berbasis intent yang jelas.

Contoh fungsi:

* loadEvents()
* createEvent()
* updateEvent()
* deleteEvent()
* markEventCompleted()
* skipEvent()
* snoozeEventReminder()
* refreshPetState()
* startLiveActivity()
* stopLiveActivity()

Contoh state:

enum DashboardViewState: Equatable {
case loading
case empty
case loaded(DashboardViewData)
case error(AppError)
}

Contoh ViewModel:

@MainActor
final class DashboardViewModel: ObservableObject {
@Published private(set) var state: DashboardViewState = .loading

```
private let eventRepository: EventRepositoryProtocol
private let petStateEngine: PetStateEngineProtocol
private let dateProvider: DateProviderProtocol

private var loadTask: Task<Void, Never>?

init(
    eventRepository: EventRepositoryProtocol,
    petStateEngine: PetStateEngineProtocol,
    dateProvider: DateProviderProtocol
) {
    self.eventRepository = eventRepository
    self.petStateEngine = petStateEngine
    self.dateProvider = dateProvider
}

func loadDashboard() {
    loadTask?.cancel()

    loadTask = Task {
        // Load dashboard data and update UI state.
    }
}

func cancelTasks() {
    loadTask?.cancel()
}
```

}

==================================================
9. VIEW RULES
=============

Setiap SwiftUI View harus:

* Fokus pada layout dan rendering.
* Menerima ViewModel melalui dependency injection.
* Memanggil intent function pada ViewModel.
* Tidak memanggil repository atau service secara langsung.
* Tidak memuat business logic.
* Menampilkan loading, empty, loaded, dan error state.
* Memiliki accessibility identifier untuk core UI test.

Contoh:

struct DashboardView: View {
@StateObject private var viewModel: DashboardViewModel

```
init(viewModel: DashboardViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
}

var body: some View {
    content
        .task {
            viewModel.loadDashboard()
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
}
```

}

==================================================
10. DEPENDENCY INJECTION
========================

Gunakan AppContainer sebagai composition root.

AppContainer bertanggung jawab untuk:

* Membuat repository.
* Membuat service.
* Membuat ViewModel.
* Menyediakan production dependency.
* Menyediakan mock dependency untuk Preview dan test.
* Menjadi satu-satunya tempat pembuatan dependency utama.

Contoh:

extension AppContainer {
func makeDashboardViewModel() -> DashboardViewModel {
DashboardViewModel(
eventRepository: makeEventRepository(),
petStateEngine: makePetStateEngine(),
dateProvider: makeDateProvider()
)
}
}

Jangan membuat ViewModel menggunakan production dependency secara hardcoded dari dalam View.

==================================================
11. SOURCE OF TRUTH DAN BUSINESS RULES
======================================

Source of truth:

1. SwiftData CalendarEvent adalah source of truth utama.
2. NotificationScheduler membaca CalendarEvent untuk membuat reminder.
3. PetStateEngine membaca event terdekat untuk menentukan mood pet.
4. LiveActivityManager membaca event terpilih untuk membuat atau memperbarui Live Activity.
5. Widget dan Live Activity hanya menampilkan snapshot data, bukan source of truth.

Service yang wajib dibuat:

* EventRepositoryProtocol
* EventRepository
* EventValidationService
* EventOccurrenceService
* EventQueryService
* NotificationSchedulerProtocol
* NotificationScheduler
* PetStateEngineProtocol
* PetStateEngine
* LiveActivityManagerProtocol
* LiveActivityManager
* LiveActivityEventResolver
* EventPriorityResolver
* DateTimeFormatterService
* NotificationPermissionManager
* CalendarSyncServiceProtocol

==================================================
12. CALENDAR EXPERIENCE
=======================

A. Dashboard

Fitur:

* Pet pada bagian utama dashboard.
* Ringkasan event terdekat.
* Countdown menuju event paling relevan.
* Tombol Add Event.
* Tombol View Calendar.
* Maksimal tiga agenda terdekat.
* Empty state bila belum ada event.
* Pet berubah mood berdasarkan jadwal pengguna.

B. Calendar View

Fitur:

* Monthly view.
* Weekly view.
* Daily agenda view.
* Event indicator pada tanggal.
* Hari ini harus jelas.
* Event high priority harus lebih menonjol.
* Tap tanggal membuka agenda hari tersebut.
* Tap event membuka event detail.

C. Agenda View

Fitur:

* Event dikelompokkan berdasarkan tanggal.
* Menampilkan jam, kategori, prioritas, status, dan reminder.
* Filter:

  * all
  * today
  * upcoming
  * completed
  * high priority

D. Event Editor

Fields:

* title
* notes
* start date
* start time
* end date
* end time
* category
* priority
* reminder
* recurrence
* show in Dynamic Island
* pet reaction style

Actions:

* save
* duplicate
* delete
* mark completed
* skip
* cancel

==================================================
13. PET EXPERIENCE
==================

Pet harus responsif di dalam aplikasi.

Interaksi MVP:

* Tap pet: pet melakukan teleport atau berpindah ke posisi aman secara acak.
* Long press pet: membuka quick action menu.
* Quick action:

  * Add Event
  * View Next Event
  * Start Focus
  * Pet Profile
* Pet memiliki idle animation ringan.
* Pet dapat berjalan hanya di area dashboard aplikasi.
* Pet tidak boleh menutupi informasi penting.
* Pet tidak boleh berpindah ke area tombol secara acak.

Pet state rules:

* Tidak ada event dalam 24 jam: relaxed atau sleeping.
* Event berikutnya lebih dari 1 jam: idle.
* Event berikutnya dalam 60 menit: alert ringan.
* Event berikutnya dalam 15 menit: alert kuat.
* Event sedang berlangsung: focused.
* Event selesai: happy atau celebrate.
* Event terlewat: concerned tanpa nada menghakimi.
* Banyak event berurutan: focused tetapi tenang.

Gamification MVP:

* Event selesai memberi XP.
* Streak bertambah jika pengguna menyelesaikan minimal satu event dalam sehari.
* Tidak ada punishment ekstrem untuk event terlewat.
* Jangan mengurangi XP karena event terlewat pada MVP.

==================================================
14. DYNAMIC ISLAND DAN LIVE ACTIVITY
====================================

Tujuan:

* Menampilkan event aktif atau event penting yang segera dimulai.
* Menampilkan pet sebagai indikator status.
* Memberi akses cepat ke event terkait.
* Tidak digunakan sebagai animasi game real-time.

Buat PetLiveActivityAttributes.

Static attributes:

* eventID: UUID
* eventTitle: String
* categoryRawValue: String
* priorityRawValue: String

Content state:

* eventStatus: String
* startDate: Date
* endDate: Date
* petMoodRawValue: String
* petActionRawValue: String
* progressValue: Double?
* lastUpdatedAt: Date

Dynamic Island Layout:

A. Compact Leading

* Pet icon kecil.
* Ekspresi pet sesuai mood.
* Jangan tampilkan teks panjang.

B. Compact Trailing

* Countdown atau timer.
* Prioritaskan keterbacaan waktu.

C. Minimal

* Pet icon atau category icon.
* Gunakan satu visual utama.

D. Expanded

* Nama event.
* Waktu mulai dan selesai.
* Countdown atau progress.
* Pet visual lebih besar.
* Status event.
* Deep link ke Event Detail.
* Quick action bila didukung:

  * Complete
  * Open Event
  * Start Focus
  * Snooze reminder

E. Lock Screen Live Activity

* Pet visual.
* Event title.
* Time range.
* Progress atau countdown.
* Deep link ke event detail.

Live Activity policy:

* Hanya satu Live Activity aktif.
* Event aktif menggantikan event upcoming.
* Event urgent dapat menggantikan event normal.
* Jangan tampilkan Live Activity untuk event yang terlalu jauh.
* Jangan tampilkan Live Activity untuk event selesai.
* Hentikan Live Activity saat event selesai, dibatalkan, atau ditandai selesai.
* Gunakan fallback bila perangkat tidak mendukung Dynamic Island.

MVP behavior:

* Sediakan tombol manual “Show Next Event in Dynamic Island”.
* Saat app aktif atau kembali foreground, evaluasi event terdekat.
* Update Live Activity sesuai event paling relevan.
* Jangan mengandalkan Live Activity untuk otomatis mulai secara presisi saat app tidak aktif.
* Reminder notification harus tetap independen dari Live Activity.
* Siapkan abstraction untuk future remote push update tanpa mengubah domain layer.

==================================================
15. NOTIFICATION STRATEGY
=========================

Gunakan local notification pada MVP.

Notification flow:

1. Pengguna membuat atau mengubah event.
2. EventValidationService memvalidasi event.
3. NotificationScheduler menghapus reminder lama.
4. NotificationScheduler membuat reminder baru.
5. Saat event dihapus, semua reminder terkait dibatalkan.
6. Saat event selesai, reminder masa depan dibatalkan.
7. Saat app dibuka, lakukan reconciliation reminder dengan event aktif.

Notification categories:

* EVENT_REMINDER
* EVENT_STARTING
* EVENT_OVERDUE
* FOCUS_SESSION

Notification actions:

* Complete
* Snooze 10 Minutes
* Open Event
* Skip Event

Format identifier notification:
event.{eventUUID}.reminder.{offsetIdentifier}

Pastikan:

* Reminder masa lalu tidak dijadwalkan ulang.
* Tidak ada duplicate notification request.
* Event dengan banyak reminder tetap stabil.
* Gunakan rolling scheduling strategy jika jumlah event besar.
* Notification code dapat diuji dengan mock.

==================================================
16. PERMISSION DAN PRIVACY
==========================

Permission rules:

* Notification permission hanya diminta ketika pengguna membuat event pertama dengan reminder.
* Calendar permission hanya diminta setelah pengguna memilih Apple Calendar Sync.
* Jangan meminta akses kalender penuh jika write access sudah cukup.
* Jelaskan alasan permission dengan bahasa sederhana.

Privacy MVP:

* Semua event disimpan secara lokal.
* Tidak ada login.
* Tidak ada backend.
* Tidak ada analytics pihak ketiga.
* Tidak ada pengiriman data kalender ke server.
* Jangan tampilkan informasi event sensitif di Live Activity tanpa pilihan pengguna.

==================================================
17. DESIGN SYSTEM
=================

Buat internal design system:

* AppSpacing
* AppRadius
* AppTypography
* AppIcon
* AppColorToken
* PetVisualToken
* EventCategoryVisualToken

UI requirements:

* Support light mode.
* Support dark mode.
* Support Dynamic Type.
* Support VoiceOver.
* Contrast cukup.
* Jangan menggunakan warna saja untuk membedakan status.
* Semua icon harus memiliki accessibility label.
* Bahasa Indonesia sebagai localization default.
* Siapkan struktur untuk English localization.

==================================================
18. ROADMAP IMPLEMENTATION
==========================

FASE 0 — PROJECT FOUNDATION

Tujuan:

* Membuat project yang rapi, buildable, dan siap menggunakan MVVM.

Implementasi:

* SwiftUI app shell.
* SwiftData container.
* AppContainer.
* RootView dan RootViewModel.
* Tab navigation.
* Empty Dashboard.
* Empty Calendar.
* Empty Settings.
* Design token dasar.
* DateProvider.
* AppError.
* OSLog setup.
* Test target.
* UI test target.
* Preview mock data.
* README dasar.

Acceptance criteria:

* Project build tanpa warning kritis.
* Semua root screen memiliki ViewModel.
* Semua ViewModel dibuat oleh AppContainer.
* View tidak mengakses service/persistence langsung.
* SwiftData berhasil diinisialisasi.
* Ada minimal satu unit test RootViewModel dan DashboardViewModel.
* Preview menggunakan mock data.

FASE 1 — EVENT DOMAIN DAN PERSISTENCE

Tujuan:

* Membangun fondasi data calendar event.

Implementasi:

* CalendarEvent model.
* Category, priority, status, recurrence model.
* SwiftData persistence entity.
* EventRepository.
* EventValidationService.
* Preview sample event.
* Unit test validasi event.

Acceptance criteria:

* Event bisa create, read, update, delete.
* Title validation bekerja.
* Date validation bekerja.
* Data bertahan setelah app restart.
* Unit test lulus.

FASE 2 — CALENDAR DAN EVENT EDITOR

Tujuan:

* Membuat pengguna bisa mengelola jadwal.

Implementasi:

* Monthly calendar.
* Daily agenda.
* Agenda list.
* Event editor.
* Event detail.
* Create, update, delete, complete, skip event.
* Filter agenda dasar.

Acceptance criteria:

* Event baru dapat dibuat.
* Event muncul pada hari yang benar.
* Event dapat diedit dan dihapus.
* Event status dapat diubah.
* UI mendukung Dynamic Type.

FASE 3 — NOTIFICATION SYSTEM

Tujuan:

* Membuat reminder jadwal stabil.

Implementasi:

* NotificationPermissionManager.
* NotificationScheduler.
* Notification categories.
* Notification actions.
* Reminder scheduling.
* Reminder rescheduling.
* Reminder reconciliation saat app aktif.
* Mock notification scheduler.

Acceptance criteria:

* Reminder dibuat saat event dibuat.
* Reminder dibatalkan saat event dihapus.
* Reminder diperbarui saat event diubah.
* Complete dan Snooze action bekerja.
* Unit test notification logic lulus.

FASE 4 — PET CORE EXPERIENCE

Tujuan:

* Menambahkan pet tanpa mengganggu kalender.

Implementasi:

* PetProfile.
* PetStateEngine.
* Pet dashboard component.
* Idle, blink, walk, teleport, focus, celebrate state.
* Tap-to-teleport.
* Mood berdasarkan event terdekat.
* XP dan streak dasar.
* Pet quick action.

Acceptance criteria:

* Pet bereaksi berdasarkan event terdekat.
* Tap pet menghasilkan interaksi visual.
* Pet tidak menutupi elemen penting.
* Pet state dapat diuji.
* Dashboard dapat dipakai tanpa animation.

FASE 5 — LIVE ACTIVITY DAN DYNAMIC ISLAND

Tujuan:

* Menampilkan event relevan di Lock Screen dan Dynamic Island.

Implementasi:

* Widget extension.
* PetLiveActivityAttributes.
* Lock Screen Live Activity.
* Dynamic Island compact layout.
* Dynamic Island minimal layout.
* Dynamic Island expanded layout.
* LiveActivityManager.
* LiveActivityEventResolver.
* Manual trigger “Show Next Event”.
* Deep link ke Event Detail.
* Fallback state.

Acceptance criteria:

* Live Activity bisa dimulai untuk event terpilih.
* Compact, minimal, dan expanded layout tampil benar.
* Event title tidak overflow.
* Countdown berjalan benar.
* Deep link membuka event yang benar.
* Event selesai menutup Live Activity.
* Hanya satu Live Activity aktif.

FASE 6 — LIVE ACTIVITY AUTOMATION STRATEGY

Tujuan:

* Membuat Live Activity relevan tanpa mengandalkan perilaku background yang tidak stabil.

Implementasi:

* Evaluasi event saat app active.
* Refresh Live Activity saat app foreground.
* Start/update/end policy.
* Feature flag untuk capability iOS baru.
* Adapter untuk remote push Live Activity update di masa depan.
* Dokumentasikan limitasi local-only Live Activity.

Acceptance criteria:

* Event relevan dipilih secara deterministik.
* Event aktif lebih prioritas daripada event upcoming.
* Live Activity tidak dibiarkan aktif setelah event selesai.
* Reminder tetap berjalan walau Live Activity tidak aktif.

FASE 7 — APPLE CALENDAR INTEGRATION

Tujuan:

* Memberikan integrasi Apple Calendar opsional.

Implementasi:

* EventKit permission flow.
* Read/write scope sesuai kebutuhan.
* Import selected calendars.
* Event mapping.
* Duplicate handling.
* Sync status UI.
* Error handling jika permission ditolak.

Acceptance criteria:

* Pengguna dapat memilih calendar untuk diimpor.
* Tidak ada duplicate saat sync ulang.
* Permission denial tidak merusak calendar internal.
* Event internal tetap berfungsi tanpa EventKit.

FASE 8 — POLISH, WIDGETS, DAN QUALITY

Tujuan:

* Menyiapkan aplikasi untuk beta testing.

Implementasi:

* Home Screen widget.
* Lock Screen widget.
* Empty state.
* Onboarding.
* Settings.
* Localization.
* Accessibility audit.
* Performance profiling.
* UI test tambahan.
* Error logging.
* Backup/export plan untuk fase selanjutnya.

Acceptance criteria:

* Widget menampilkan event berikutnya.
* Dark mode berjalan.
* VoiceOver basic berjalan.
* Core flow memiliki UI test.
* Tidak ada crash pada empty state.
* Tidak ada hardcoded UI string.

==================================================
19. TESTING REQUIREMENTS
========================

Buat test untuk:

* Event title kosong.
* endDate lebih awal dari startDate.
* Event lintas hari.
* Event lintas timezone.
* Event recurrence daily.
* Event recurrence weekly.
* Event selesai.
* Event dihapus.
* Reminder dijadwalkan ulang.
* Event urgent mengalahkan normal.
* Event aktif mengalahkan upcoming.
* Pet mood berdasarkan event terdekat.
* Pet XP setelah event selesai.
* Live Activity event selection.
* Fallback tanpa Dynamic Island.
* Deep link ke Event Detail.
* ViewModel loading state.
* ViewModel empty state.
* ViewModel error state.
* ViewModel user action.
* Task cancellation bila relevan.

Gunakan dependency injection untuk:

* Clock atau DateProvider.
* CalendarProvider.
* TimeZone.
* NotificationScheduler.
* EventRepository.
* LiveActivityManager.

Jangan gunakan Date() langsung dalam business logic.

==================================================
20. CODING STANDARDS
====================

* Terapkan MVVM konsisten di setiap feature.
* ViewModel adalah satu-satunya presentation layer yang mengubah UI state.
* View tidak boleh memiliki business logic.
* View tidak boleh mengakses persistence layer atau service.
* Domain model tidak boleh bergantung pada SwiftUI, WidgetKit, atau ActivityKit.
* Gunakan protocol-based dependency injection.
* Gunakan enum type-safe.
* Hindari stringly typed logic.
* Pisahkan domain model dan persistence model jika kompleksitas meningkat.
* Semua error harus memiliki user-facing message yang jelas.
* Semua UI state harus menangani loading, empty, loaded, dan error.
* Semua async work harus aman terhadap cancellation.
* Jangan gunakan force unwrap.
* Jangan menggunakan hardcoded color atau font di luar Design System.
* Gunakan mock untuk Preview dan unit test.
* Tambahkan comment hanya untuk keputusan yang tidak obvious.
* Jangan tinggalkan TODO tanpa konteks.
* Semua core UI perlu accessibility identifier.

==================================================
21. WORKING PROTOCOL
====================

Saat mulai bekerja:

1. Jangan membangun semua fase sekaligus.
2. Mulai hanya dari FASE 0.
3. Sebelum coding, tuliskan:

   * scope fase
   * file yang dibuat atau diubah
   * asumsi teknis
   * test plan
4. Implementasikan fase tersebut.
5. Setelah implementasi, tampilkan:

   * ringkasan file yang dibuat atau diubah
   * alasan keputusan arsitektur
   * cara menjalankan aplikasi
   * cara menjalankan test
   * known limitations
   * checklist acceptance criteria
6. Tunggu instruksi eksplisit “Lanjut Fase X” sebelum melanjutkan.
7. Jangan membuat backend, cloud sync, atau EventKit sync sebelum fase terkait.
8. Jika requirement tidak dapat dijalankan secara andal dalam lifecycle iOS, jelaskan limitasinya lalu implementasikan fallback paling stabil.
9. Prioritaskan aplikasi yang stabil, testable, maintainable, dan buildable pada setiap fase.
10. Jangan mengubah struktur MVVM tanpa menjelaskan alasan teknisnya.

Mulai sekarang hanya dengan FASE 0.
