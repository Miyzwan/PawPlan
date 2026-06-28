Bertindaklah sebagai Lead iOS Engineer, watchOS Engineer, SwiftUI Architect, dan Product Engineer untuk membangun aplikasi native Apple ecosystem bernama sementara:

“PawPlan” / “Pet Calendar”

Aplikasi ini adalah personal calendar dan scheduler dengan virtual pet sebagai asisten visual. Pet bereaksi terhadap agenda pengguna, memberi konteks visual untuk jadwal terdekat, muncul secara kontekstual melalui Dynamic Island dan Live Activity di iPhone, serta tersedia sebagai companion experience di Apple Watch.

Jangan membangun seluruh aplikasi sekaligus. Implementasikan aplikasi berdasarkan fase pengembangan yang ditentukan. Setiap fase harus menghasilkan project yang bisa di-build, dijalankan, diuji, dan dikembangkan ke fase berikutnya.

Gunakan Bahasa Indonesia untuk penjelasan teknis kepada developer, tetapi gunakan Bahasa Inggris untuk nama file, class, struct, enum, protocol, variable, function, dan komentar kode.

==================================================

1. PRODUCT OVERVIEW
   ==================================================

Buat aplikasi kalender dan personal planner dengan virtual pet sebagai pendamping produktivitas.

Platform utama:

* iPhone sebagai aplikasi utama dan source of truth.
* Apple Watch sebagai companion app untuk agenda cepat, pet status, quick actions, dan complication.
* Dynamic Island sebagai surface kontekstual untuk event penting di iPhone.
* Home Screen, Lock Screen, dan Watch widgets sebagai surface informasi sekunder.

Fungsi utama aplikasi:

* Pengguna dapat membuat, melihat, mengubah, menghapus, dan menyelesaikan event kalender.
* Pengguna dapat mengatur reminder untuk setiap event.
* Pengguna dapat melihat agenda harian, mingguan, bulanan, dan daftar event mendatang.
* Virtual pet bereaksi terhadap status jadwal pengguna.
* Pet muncul di dashboard iPhone dan dapat berinteraksi melalui tap.
* Dynamic Island dan Live Activity menampilkan status event penting atau event aktif di iPhone.
* Apple Watch menampilkan event aktif, event berikutnya, agenda hari ini, dan status pet.
* Pengguna dapat menandai event selesai, skip, atau snooze dari Apple Watch.
* Local notification tetap menjadi sistem reminder utama.
* Dynamic Island, Watch complication, dan Smart Stack adalah pelengkap visual dan quick action, bukan satu-satunya sistem reminder.
* Aplikasi harus tetap berfungsi penuh tanpa Dynamic Island dan tanpa Apple Watch.

Target pengguna:

* Pelajar.
* Mahasiswa.
* Pekerja.
* Pengguna personal productivity app.
* Pengguna iPhone dan Apple Watch yang menyukai gamification ringan.

Gaya produk:

* Clean.
* Calm.
* Cute tetapi tidak terlalu kekanak-kanakan.
* Produktif.
* Mudah dibaca.
* Fokus pada kalender dan reminder.
* Pet terasa hidup tanpa mengganggu fokus.
* Apple Watch UI harus sangat ringkas, cepat dibaca, dan mudah digunakan dengan satu tangan.

==================================================
2. PRODUCT PRINCIPLES
=====================

1. Calendar dan reminder adalah fitur inti.
2. Pet adalah lapisan pengalaman visual, bukan fitur yang mengorbankan usability kalender.
3. iPhone adalah source of truth utama untuk event, reminder, dan status pet.
4. Apple Watch adalah companion app dengan local mirrored cache, bukan source of truth utama.
5. Semua event harus tetap bisa digunakan tanpa Dynamic Island.
6. Semua event harus tetap bisa digunakan tanpa Apple Watch.
7. Semua event harus tetap bisa diingatkan dengan local notification.
8. Jangan membuat aplikasi bergantung pada background execution untuk pet.
9. Jangan membuat pet berjalan bebas secara real-time di Dynamic Island atau Apple Watch.
10. Dynamic Island hanya menampilkan state pet ringan:

* idle
* relaxed
* alert
* focused
* happy
* sleeping

11. Apple Watch hanya menampilkan visual pet ringan dan hemat baterai.
12. Hanya satu Live Activity utama yang aktif untuk aplikasi ini.
13. Event aktif lebih prioritas daripada event upcoming.
14. Event urgent lebih prioritas daripada event normal.
15. Permission hanya diminta ketika pengguna membutuhkan fiturnya.
16. MVP harus berjalan lokal tanpa backend, login, atau cloud sync.
17. Semua business logic harus testable.
18. Semua View harus ringan dan tidak berisi business logic.
19. Jangan menjadwalkan reminder duplikat di iPhone dan Apple Watch untuk event yang sama pada MVP.
20. Saat Apple Watch tidak terhubung, tampilkan data cache terakhir dengan status sinkronisasi yang jelas.

==================================================
3. PLATFORM DAN TECH STACK
==========================

Minimum platform:

* iOS 17.0+
* watchOS 10.0+
* Swift 5.9+
* SwiftUI
* SwiftData
* WidgetKit
* ActivityKit
* UserNotifications
* WatchConnectivity
* EventKit untuk fase integrasi Apple Calendar
* AppIntents untuk quick actions bila diperlukan
* OSLog untuk logging
* Swift Concurrency menggunakan async/await

Target project:

* PetCalendarApp: iOS app target.
* PetCalendarWatchApp: watchOS companion app target.
* PetCalendarWidgets: iOS WidgetKit extension.
* PetCalendarWatchWidgets: watchOS WidgetKit extension.
* PetCalendarShared: shared Swift package atau shared framework untuk domain model, protocol, sync payload, dan rules.

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
* App Group sebagai pengganti WatchConnectivity untuk transfer iPhone ke Apple Watch.

==================================================
4. ARCHITECTURE — FEATURE-FIRST MVVM
====================================

Gunakan arsitektur Feature-First MVVM.

Prinsip MVVM:

* View bertanggung jawab untuk rendering UI dan menerima input pengguna.
* ViewModel bertanggung jawab untuk presentation logic, state UI, validasi ringan, dan pemanggilan service/use case.
* Model domain tidak boleh bergantung pada SwiftUI, WidgetKit, ActivityKit, WatchKit, atau WatchConnectivity.
* Service menangani business logic, persistence, notification, Live Activity, Watch sync, dan calendar integration.
* ViewModel harus mengakses dependency melalui protocol.
* Dependency injection harus menggunakan AppContainer atau DependencyContainer.
* Semua ViewModel harus dapat diuji menggunakan mock dependency.
* Semua ViewModel harus menggunakan @MainActor bila mengelola UI state.
* Jangan menyimpan SwiftUI View di dalam ViewModel.
* Jangan meletakkan warna, font, atau layout UI di ViewModel.
* Jangan memanggil Date() langsung dalam business logic. Gunakan DateProvider.
* Jangan akses ModelContext langsung dari View atau ViewModel.
* iPhone dan Apple Watch harus berbagi domain model dan sync payload melalui PetCalendarShared.
* Persistence iPhone dan persistence Watch harus dipisahkan.
* Watch hanya menyimpan snapshot event yang relevan, snapshot pet, serta command outbox lokal.

==================================================
5. PROJECT DIRECTORY
====================

Gunakan struktur folder berikut:

PetCalendarProject/
├── Packages/
│   └── PetCalendarShared/
│       ├── Package.swift
│       ├── Sources/
│       │   └── PetCalendarShared/
│       │       ├── Domain/
│       │       │   ├── CalendarEvent.swift
│       │       │   ├── EventCategory.swift
│       │       │   ├── EventPriority.swift
│       │       │   ├── EventStatus.swift
│       │       │   ├── ReminderOffset.swift
│       │       │   ├── RecurrenceRule.swift
│       │       │   ├── EventSource.swift
│       │       │   ├── PetProfile.swift
│       │       │   ├── PetSpecies.swift
│       │       │   ├── PetMood.swift
│       │       │   ├── PetAction.swift
│       │       │   └── PetReactionPreset.swift
│       │       │
│       │       ├── Sync/
│       │       │   ├── WatchSyncSnapshot.swift
│       │       │   ├── WatchEventSnapshot.swift
│       │       │   ├── WatchPetSnapshot.swift
│       │       │   ├── WatchCommandEnvelope.swift
│       │       │   ├── WatchCommandType.swift
│       │       │   ├── WatchSyncStatus.swift
│       │       │   └── SyncPayloadVersion.swift
│       │       │
│       │       ├── Protocols/
│       │       │   ├── DateProviderProtocol.swift
│       │       │   ├── CalendarProviderProtocol.swift
│       │       │   └── EventRepositoryProtocol.swift
│       │       │
│       │       ├── Rules/
│       │       │   ├── EventPriorityResolver.swift
│       │       │   ├── EventValidationRules.swift
│       │       │   ├── PetStateRules.swift
│       │       │   └── WatchEventSelectionRules.swift
│       │       │
│       │       └── Errors/
│       │           └── AppError.swift
│       │
│       └── Tests/
│
├── PetCalendarApp/
│   ├── App/
│   │   ├── PetCalendarApp.swift
│   │   ├── AppContainer.swift
│   │   ├── RootView.swift
│   │   ├── RootViewModel.swift
│   │   ├── AppRouter.swift
│   │   └── AppSettings.swift
│   │
│   ├── Core/
│   │   ├── DesignSystem/
│   │   ├── DateTime/
│   │   ├── Logging/
│   │   ├── Localization/
│   │   ├── Extensions/
│   │   ├── Utilities/
│   │   └── DependencyInjection/
│   │
│   ├── Persistence/
│   │   ├── Entities/
│   │   │   ├── CalendarEventEntity.swift
│   │   │   └── PetProfileEntity.swift
│   │   ├── SwiftDataModelContainer.swift
│   │   └── PersistenceMapper.swift
│   │
│   ├── Services/
│   │   ├── Event/
│   │   │   ├── EventRepository.swift
│   │   │   ├── EventValidationService.swift
│   │   │   ├── EventOccurrenceService.swift
│   │   │   └── EventQueryService.swift
│   │   │
│   │   ├── Notification/
│   │   │   ├── NotificationSchedulerProtocol.swift
│   │   │   ├── NotificationScheduler.swift
│   │   │   ├── NotificationPermissionManager.swift
│   │   │   └── NotificationActionHandler.swift
│   │   │
│   │   ├── Pet/
│   │   │   ├── PetStateEngineProtocol.swift
│   │   │   ├── PetStateEngine.swift
│   │   │   ├── PetAnimationResolver.swift
│   │   │   └── PetRewardService.swift
│   │   │
│   │   ├── LiveActivity/
│   │   │   ├── LiveActivityManagerProtocol.swift
│   │   │   ├── LiveActivityManager.swift
│   │   │   ├── LiveActivityEventResolver.swift
│   │   │   └── PetLiveActivityAttributes.swift
│   │   │
│   │   ├── WatchConnectivity/
│   │   │   ├── WatchSyncManagerProtocol.swift
│   │   │   ├── WatchSyncManager.swift
│   │   │   ├── WatchSnapshotBuilder.swift
│   │   │   ├── WatchCommandProcessor.swift
│   │   │   └── WatchConnectivitySessionDelegate.swift
│   │   │
│   │   └── CalendarIntegration/
│   │       ├── CalendarSyncServiceProtocol.swift
│   │       ├── CalendarSyncService.swift
│   │       └── EventKitPermissionManager.swift
│   │
│   ├── Features/
│   │   ├── Onboarding/
│   │   ├── Dashboard/
│   │   ├── Calendar/
│   │   ├── Agenda/
│   │   ├── EventEditor/
│   │   ├── Pet/
│   │   ├── LiveActivity/
│   │   ├── WatchIntegration/
│   │   └── Settings/
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── Localizable.xcstrings
│   │   └── PreviewContent/
│   │
│   └── Tests/
│       ├── Mocks/
│       ├── UnitTests/
│       ├── IntegrationTests/
│       └── UITests/
│
├── PetCalendarWidgets/
│   ├── PetCalendarWidgetBundle.swift
│   ├── NextEventWidget.swift
│   ├── PetLiveActivity.swift
│   ├── PetLiveActivityDynamicIsland.swift
│   └── WidgetSharedDataProvider.swift
│
├── PetCalendarWatchApp/
│   ├── App/
│   │   ├── PetCalendarWatchApp.swift
│   │   ├── WatchAppContainer.swift
│   │   ├── WatchRootView.swift
│   │   └── WatchRootViewModel.swift
│   │
│   ├── Persistence/
│   │   ├── Entities/
│   │   │   ├── WatchEventSnapshotEntity.swift
│   │   │   ├── WatchPetSnapshotEntity.swift
│   │   │   └── WatchCommandOutboxEntity.swift
│   │   ├── WatchSwiftDataModelContainer.swift
│   │   └── WatchPersistenceMapper.swift
│   │
│   ├── Services/
│   │   ├── WatchConnectivity/
│   │   │   ├── WatchSessionManagerProtocol.swift
│   │   │   ├── WatchSessionManager.swift
│   │   │   ├── WatchSnapshotRepositoryProtocol.swift
│   │   │   ├── WatchSnapshotRepository.swift
│   │   │   ├── WatchCommandOutboxProtocol.swift
│   │   │   ├── WatchCommandOutbox.swift
│   │   │   └── WatchConnectivitySessionDelegate.swift
│   │   │
│   │   ├── Pet/
│   │   │   └── WatchPetStateResolver.swift
│   │   │
│   │   └── Haptics/
│   │       └── WatchHapticService.swift
│   │
│   ├── Features/
│   │   ├── Now/
│   │   │   ├── Views/
│   │   │   │   ├── WatchNowView.swift
│   │   │   │   └── WatchEventDetailView.swift
│   │   │   ├── ViewModels/
│   │   │   │   ├── WatchNowViewModel.swift
│   │   │   │   └── WatchEventDetailViewModel.swift
│   │   │   ├── Components/
│   │   │   │   ├── WatchPetAvatarView.swift
│   │   │   │   ├── WatchCountdownView.swift
│   │   │   │   └── WatchQuickActionButton.swift
│   │   │   └── Models/
│   │   │       └── WatchNowViewState.swift
│   │   │
│   │   ├── Today/
│   │   │   ├── Views/
│   │   │   │   └── WatchTodayView.swift
│   │   │   ├── ViewModels/
│   │   │   │   └── WatchTodayViewModel.swift
│   │   │   ├── Components/
│   │   │   │   └── WatchAgendaRow.swift
│   │   │   └── Models/
│   │   │       └── WatchTodayViewState.swift
│   │   │
│   │   ├── Pet/
│   │   │   ├── Views/
│   │   │   │   └── WatchPetView.swift
│   │   │   ├── ViewModels/
│   │   │   │   └── WatchPetViewModel.swift
│   │   │   └── Components/
│   │   │       ├── WatchPetMoodBadge.swift
│   │   │       └── WatchPetProgressView.swift
│   │   │
│   │   └── Settings/
│   │       ├── Views/
│   │       │   └── WatchSettingsView.swift
│   │       └── ViewModels/
│   │           └── WatchSettingsViewModel.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── Localizable.xcstrings
│   │
│   └── Tests/
│       ├── Mocks/
│       ├── UnitTests/
│       └── UITests/
│
└── PetCalendarWatchWidgets/
├── PetCalendarWatchWidgetBundle.swift
├── NextEventComplication.swift
├── PetStatusComplication.swift
├── WatchSmartStackWidget.swift
└── WatchWidgetTimelineProvider.swift

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

Sync payload:

* Watch[Purpose]Snapshot.swift
* Watch[Purpose]Envelope.swift

Contoh:

* DashboardView
* DashboardViewModel
* WatchNowView
* WatchNowViewModel
* WatchSyncSnapshot
* WatchCommandEnvelope
* EventValidationService
* WatchSyncManagerProtocol

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

Jangan membuat recurrence engine terlalu kompleks pada fase awal. Buat fondasi yang mudah dikembangkan.

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
8. APPLE WATCH SYNC MODELS
==========================

Buat sync model yang ringkas, versioned, dan Codable.

A. WatchSyncSnapshot

Properties:

* schemaVersion: Int
* syncID: UUID
* generatedAt: Date
* sourceDeviceIdentifier: String
* activeEvent: WatchEventSnapshot?
* nextEvent: WatchEventSnapshot?
* todayEvents: [WatchEventSnapshot]
* pet: WatchPetSnapshot
* lastSuccessfulSyncAt: Date?
* syncStatus: WatchSyncStatus

Rules:

* Hanya kirim data minimum yang dibutuhkan Watch.
* Jangan mengirim seluruh history event.
* Kirim maksimal event hari ini dan event terdekat dalam periode yang ditentukan.
* Batasi notes atau jangan kirim notes ke Watch pada MVP.
* Semua payload harus memiliki schemaVersion.
* Semua payload harus dapat dideserialisasi secara aman.
* Payload versi lama harus ditangani secara graceful.

B. WatchEventSnapshot

Properties:

* eventID: UUID
* title: String
* startDate: Date
* endDate: Date
* category: EventCategory
* priority: EventPriority
* status: EventStatus
* showQuickActions: Bool
* isCurrentlyRelevant: Bool

C. WatchPetSnapshot

Properties:

* petName: String
* species: PetSpecies
* mood: PetMood
* action: PetAction
* energyLevel: Int
* level: Int
* experiencePoints: Int
* selectedAccessory: String?

D. WatchCommandEnvelope

Properties:

* commandID: UUID
* idempotencyKey: UUID
* eventID: UUID
* commandType: WatchCommandType
* createdAt: Date
* payloadVersion: Int
* metadata: [String: String]

E. WatchCommandType

Cases:

* completeEvent
* skipEvent
* snoozeReminder
* requestFullSync
* openEventOnPhone

F. WatchSyncStatus

Cases:

* upToDate
* syncing
* stale
* unavailable
* failed

==================================================
9. WATCHCONNECTIVITY STRATEGY
=============================

Gunakan WatchConnectivity untuk komunikasi iPhone dan Apple Watch.

Aturan komunikasi:

1. iPhone adalah authority utama untuk CalendarEvent.
2. Apple Watch menyimpan cache snapshot terakhir yang berhasil diterima.
3. Apple Watch tidak menyimpan full event database pada MVP.
4. Apple Watch tidak boleh mengubah event secara langsung pada persistence utama.
5. Semua action dari Watch dikirim sebagai WatchCommandEnvelope.
6. iPhone memproses command secara idempotent.
7. iPhone mengirim snapshot authoritative kembali ke Watch setelah command berhasil diproses.
8. Bila Watch tidak dapat menjangkau iPhone, command disimpan pada WatchCommandOutbox.
9. Command outbox harus diproses kembali ketika koneksi tersedia.
10. Jangan menganggap sendMessage selalu tersedia.
11. Gunakan immediate message hanya untuk action yang membutuhkan respons cepat.
12. Gunakan background transfer untuk command atau data yang tetap harus dikirim bila counterpart tidak reachable.
13. Gunakan application context untuk snapshot state terbaru yang dapat menggantikan snapshot lama.
14. Jangan menggunakan WatchConnectivity untuk transfer asset besar pada MVP.
15. Semua payload harus kecil, serializable, versioned, dan aman.

Gunakan mekanisme berikut:

A. updateApplicationContext
Digunakan untuk:

* Snapshot agenda terbaru.
* Snapshot pet terbaru.
* Status sync terbaru.
* Event aktif dan event berikutnya.
* Data yang hanya membutuhkan versi paling baru.

B. transferUserInfo
Digunakan untuk:

* Command completion dari Watch.
* Command skip dari Watch.
* Command snooze dari Watch.
* Permintaan full sync.
* Transfer yang harus tetap dikirim ketika counterpart sedang tidak reachable.

C. sendMessage
Digunakan hanya untuk:

* Refresh manual ketika app iPhone dan Watch sama-sama reachable.
* Quick response untuk action yang membutuhkan feedback cepat.
* Jangan jadikan satu-satunya transport untuk command penting.

D. Command outbox di Watch

* Persist command lokal sebelum dikirim.
* Tandai command sebagai pending, sent, acknowledged, atau failed.
* Jangan kirim ulang command yang sudah acknowledged.
* Gunakan idempotencyKey agar command duplikat aman.
* Jika event sudah tidak tersedia ketika command diproses, kembalikan error state yang jelas.

==================================================
10. VIEWMODEL RULES
===================

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
* Menangani kondisi data stale pada Apple Watch.
* Menampilkan optimistic state secara hati-hati pada Apple Watch.
* Tidak menganggap command Watch sukses sebelum authoritative sync diterima, kecuali state optimistic diberi status pending.

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
* refreshWatchSnapshot()
* sendWatchCommand()
* retryPendingWatchCommands()

==================================================
11. VIEW RULES
==============

Setiap SwiftUI View harus:

* Fokus pada layout dan rendering.
* Menerima ViewModel melalui dependency injection.
* Memanggil intent function pada ViewModel.
* Tidak memanggil repository atau service secara langsung.
* Tidak memuat business logic.
* Menampilkan loading, empty, loaded, dan error state.
* Memiliki accessibility identifier untuk core UI test.

Aturan khusus watchOS:

* Jangan membangun monthly calendar kompleks pada Apple Watch.
* Prioritaskan Now, Today, dan quick action.
* Hindari list panjang.
* Gunakan teks besar, ringkas, dan mudah dibaca.
* Gunakan Digital Crown untuk scrolling secara natural.
* Hindari animasi yang berlebihan.
* Gunakan haptic hanya untuk feedback action yang penting.
* Selalu tampilkan “last synced” bila cache Watch stale.
* Event title panjang harus dipotong secara elegan.
* Informasi penting tidak boleh hanya disampaikan lewat warna.

==================================================
12. DEPENDENCY INJECTION
========================

Gunakan AppContainer sebagai composition root untuk iOS.

Gunakan WatchAppContainer sebagai composition root untuk watchOS.

AppContainer bertanggung jawab untuk:

* Membuat repository iPhone.
* Membuat service iPhone.
* Membuat ViewModel iPhone.
* Membuat WatchSyncManager.
* Menyediakan production dependency.
* Menyediakan mock dependency untuk Preview dan test.

WatchAppContainer bertanggung jawab untuk:

* Membuat WatchSnapshotRepository.
* Membuat WatchSessionManager.
* Membuat WatchCommandOutbox.
* Membuat Watch ViewModel.
* Menyediakan mock dependency untuk Preview dan test.

Jangan membuat ViewModel menggunakan production dependency secara hardcoded dari dalam View.

==================================================
13. SOURCE OF TRUTH DAN BUSINESS RULES
======================================

Source of truth:

1. SwiftData CalendarEvent di iPhone adalah source of truth utama.
2. NotificationScheduler iPhone membaca CalendarEvent untuk membuat reminder.
3. PetStateEngine iPhone membaca event terdekat untuk menentukan mood pet.
4. LiveActivityManager iPhone membaca event terpilih untuk membuat atau memperbarui Live Activity.
5. WatchSyncManager iPhone membuat WatchSyncSnapshot dari data utama.
6. WatchSnapshotRepository menyimpan cache snapshot di Apple Watch.
7. Widget, Dynamic Island, Live Activity, complication, dan Smart Stack hanya menampilkan snapshot data.
8. Apple Watch command tidak dianggap final sampai iPhone memproses command dan mengirim snapshot authoritative terbaru.

Service yang wajib dibuat:

iPhone:

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
* WatchSyncManagerProtocol
* WatchSyncManager
* WatchSnapshotBuilder
* WatchCommandProcessor
* NotificationPermissionManager
* CalendarSyncServiceProtocol

Apple Watch:

* WatchSessionManagerProtocol
* WatchSessionManager
* WatchSnapshotRepositoryProtocol
* WatchSnapshotRepository
* WatchCommandOutboxProtocol
* WatchCommandOutbox
* WatchPetStateResolver
* WatchHapticService

==================================================
14. IPHONE CALENDAR EXPERIENCE
==============================

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
* Status sync Apple Watch bila paired.
* Tombol manual refresh Apple Watch pada Settings atau Watch Integration.

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
* show on Apple Watch

Actions:

* save
* duplicate
* delete
* mark completed
* skip
* cancel

==================================================
15. PET EXPERIENCE
==================

Pet harus responsif di dalam aplikasi.

Interaksi iPhone MVP:

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

Apple Watch pet rules:

* Pet tampil sebagai avatar atau icon statis dengan transisi ringan.
* Jangan membuat pet berjalan secara kontinyu.
* Tap pet membuka WatchPetView.
* Mood pet mengikuti WatchPetSnapshot.
* Tampilkan pet mood, energy, level, dan XP secara ringkas.
* Gunakan haptic ringan saat pengguna menyelesaikan event dari Watch.
* Jangan gunakan gamification yang mengganggu saat pengguna sedang melihat agenda penting.

Gamification MVP:

* Event selesai memberi XP.
* Streak bertambah jika pengguna menyelesaikan minimal satu event dalam sehari.
* Tidak ada punishment ekstrem untuk event terlewat.
* Jangan mengurangi XP karena event terlewat pada MVP.

==================================================
16. DYNAMIC ISLAND DAN LIVE ACTIVITY
====================================

Dynamic Island hanya berlaku pada iPhone.

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

==================================================
17. APPLE WATCH EXPERIENCE
==========================

Apple Watch digunakan sebagai companion app, bukan salinan penuh aplikasi iPhone.

A. Watch Root Navigation

Buat tiga area utama:

* Now
* Today
* Pet

B. Watch Now View

Tujuan:

* Menampilkan event aktif atau event berikutnya.
* Menampilkan countdown.
* Menampilkan pet mood yang relevan.
* Menyediakan quick action.

Konten:

* Pet avatar.
* Event title.
* Start dan end time.
* Countdown atau status active.
* Priority indicator.
* Category icon.
* Last sync information jika data stale.
* Action:

  * Complete
  * Skip
  * Snooze 10 Minutes
  * Open on iPhone

Rules:

* Bila ada event aktif, tampilkan event aktif.
* Bila tidak ada event aktif, tampilkan event berikutnya.
* Bila tidak ada event hari ini, tampilkan empty state dan pet relaxed.
* Bila Watch offline, gunakan snapshot terakhir.
* Bila command sedang pending, tampilkan status “Syncing”.

C. Watch Today View

Tujuan:

* Menampilkan agenda hari ini secara ringkas.

Konten:

* Daftar event hari ini.
* Maksimal event sesuai space layar dan scroll.
* Jam mulai.
* Category icon.
* Priority marker.
* Status completed atau upcoming.
* Tap event membuka WatchEventDetailView.

Rules:

* Jangan tampilkan notes panjang.
* Jangan tampilkan monthly grid.
* Prioritaskan event aktif, lalu event berikutnya.
* Grouping boleh berdasarkan pagi, siang, sore, malam.

D. Watch Event Detail View

Konten:

* Judul event.
* Time range.
* Category.
* Priority.
* Status.
* Quick action.
* Status sync jika command pending.
* Tombol “Open on iPhone” melalui deep link atau handoff equivalent yang tersedia.

E. Watch Pet View

Konten:

* Avatar pet.
* Mood.
* Energy.
* Level.
* XP progress.
* Streak ringkas.
* Next event relation.
* Tidak ada animasi berat.

F. Watch Settings View

Konten:

* Sync status.
* Last successful sync.
* Manual refresh.
* Enable/disable watch haptic feedback.
* Privacy explanation.
* Troubleshooting paired device unavailable.

==================================================
18. APPLE WATCH WIDGETS, SMART STACK, DAN COMPLICATION
======================================================

Buat WidgetKit extension untuk Apple Watch.

A. Next Event Complication

Tujuan:

* Menampilkan event terdekat.

Konten:

* Category icon.
* Waktu countdown atau jam mulai.
* Pet mood kecil jika layout memungkinkan.
* Deep link ke WatchNowView.

B. Pet Status Complication

Tujuan:

* Menampilkan kondisi pet.

Konten:

* Pet avatar.
* Mood indicator.
* Optional tiny progress indicator.

C. Smart Stack Widget

Tujuan:

* Menampilkan event aktif atau event berikutnya secara lebih informatif.

Konten:

* Pet avatar.
* Event title singkat.
* Countdown.
* Category icon.
* Quick deep link ke WatchNowView.

Aturan widget:

* Gunakan timeline yang hemat baterai.
* Jangan berharap widget reload secara real-time setiap detik.
* Gunakan data cache Watch yang terakhir valid.
* Minta reload timeline hanya ketika snapshot baru diterima atau state event penting berubah.
* Jangan menampilkan event sensitif secara penuh jika privacy mode diaktifkan.
* Semua widget harus memiliki placeholder, error state, dan empty state.

==================================================
19. NOTIFICATION STRATEGY
=========================

Gunakan local notification pada MVP dengan iPhone sebagai notification owner utama.

Notification flow iPhone:

1. Pengguna membuat atau mengubah event.
2. EventValidationService memvalidasi event.
3. NotificationScheduler menghapus reminder lama.
4. NotificationScheduler membuat reminder baru.
5. Saat event dihapus, semua reminder terkait dibatalkan.
6. Saat event selesai, reminder masa depan dibatalkan.
7. Saat app dibuka, lakukan reconciliation reminder dengan event aktif.
8. Setelah data event berubah, buat WatchSyncSnapshot terbaru.

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

Aturan Apple Watch:

* Jangan menjadwalkan local notification duplicate di Watch untuk event yang sudah dijadwalkan oleh iPhone.
* Pada MVP, Watch berfokus pada agenda cache, quick action, complication, dan sync command.
* Local notification khusus Watch hanya boleh dipertimbangkan pada fase standalone watchOS di masa depan.
* Notification action dari Watch harus tetap menghasilkan command yang idempotent.
* Bila watch command tidak dapat langsung terkirim, simpan pada outbox.

==================================================
20. PERMISSION DAN PRIVACY
==========================

Permission rules:

* Notification permission hanya diminta ketika pengguna membuat event pertama dengan reminder.
* Calendar permission hanya diminta setelah pengguna memilih Apple Calendar Sync.
* Apple Watch tidak meminta permission tambahan kecuali benar-benar diperlukan.
* Jangan meminta akses kalender penuh jika write access sudah cukup.
* Jelaskan alasan permission dengan bahasa sederhana.

Privacy MVP:

* Semua event disimpan secara lokal di iPhone.
* Apple Watch hanya menerima event snapshot minimum yang relevan.
* Jangan kirim notes atau data sensitif ke Watch pada MVP.
* Tidak ada login.
* Tidak ada backend.
* Tidak ada analytics pihak ketiga.
* Tidak ada pengiriman data kalender ke server.
* Jangan tampilkan informasi event sensitif di Dynamic Island, Lock Screen, complication, atau Smart Stack tanpa pilihan pengguna.
* Tambahkan privacy setting:

  * Show full event title
  * Show generic event label
  * Hide event details on widgets

==================================================
21. DESIGN SYSTEM
=================

Buat internal design system:

* AppSpacing
* AppRadius
* AppTypography
* AppIcon
* AppColorToken
* PetVisualToken
* EventCategoryVisualToken
* WatchTypographyToken
* WatchLayoutToken

iPhone UI requirements:

* Support light mode.
* Support dark mode.
* Support Dynamic Type.
* Support VoiceOver.
* Contrast cukup.
* Jangan menggunakan warna saja untuk membedakan status.
* Semua icon harus memiliki accessibility label.
* Bahasa Indonesia sebagai localization default.
* Siapkan struktur untuk English localization.

Watch UI requirements:

* Typography ringkas dan mudah dibaca.
* Hit target cukup besar.
* Tidak menggunakan text paragraph panjang.
* Gunakan scroll seperlunya.
* Haptic hanya untuk action penting.
* Support accessibility.
* Jangan gunakan animasi berlebihan.
* Jangan gunakan layout yang menyerupai iPhone dalam ukuran kecil.

==================================================
22. ROADMAP IMPLEMENTATION
==========================

FASE 0 — PROJECT FOUNDATION

Tujuan:

* Membuat project multi-target yang rapi, buildable, dan siap menggunakan MVVM.

Implementasi:

* iOS app target.
* watchOS companion target.
* iOS WidgetKit extension.
* watchOS WidgetKit extension.
* PetCalendarShared package.
* SwiftUI app shell.
* SwiftData container iPhone.
* SwiftData container Watch untuk cache snapshot dan outbox.
* AppContainer.
* WatchAppContainer.
* RootView dan RootViewModel.
* WatchRootView dan WatchRootViewModel.
* Tab navigation iPhone.
* Navigation dasar Watch.
* Empty Dashboard.
* Empty Calendar.
* Empty Settings.
* Empty Watch Now.
* Empty Watch Today.
* Empty Watch Pet.
* Design token dasar.
* DateProvider.
* AppError.
* OSLog setup.
* Test target.
* UI test target.
* Preview mock data.
* README dasar.

Acceptance criteria:

* Semua target build tanpa warning kritis.
* iPhone app dapat berjalan.
* Watch app dapat berjalan pada Watch Simulator.
* Semua root screen memiliki ViewModel.
* Semua ViewModel dibuat oleh AppContainer atau WatchAppContainer.
* View tidak mengakses service atau persistence langsung.
* Shared package dapat diimpor oleh iOS dan watchOS target.
* Ada minimal satu unit test RootViewModel, DashboardViewModel, dan WatchNowViewModel.
* Preview menggunakan mock data.

FASE 1 — EVENT DOMAIN DAN IPHONE PERSISTENCE

Tujuan:

* Membangun fondasi data calendar event.

Implementasi:

* CalendarEvent model.
* Category, priority, status, recurrence model.
* SwiftData persistence iPhone.
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

FASE 6 — APPLE WATCH CONNECTIVITY FOUNDATION

Tujuan:

* Membuat iPhone dan Apple Watch memiliki sistem sinkronisasi yang aman, versioned, dan testable.

Implementasi:

* WatchSyncSnapshot.
* WatchEventSnapshot.
* WatchPetSnapshot.
* WatchCommandEnvelope.
* WatchCommandOutbox.
* WatchSyncManager di iPhone.
* WatchSessionManager di Watch.
* WCSession activation dan lifecycle handling.
* Application context sync.
* Background user info command transfer.
* Manual sync request.
* Snapshot cache di Watch.
* Stale status.
* Idempotent command processor.
* Mock WatchConnectivity dependency.

Acceptance criteria:

* Watch menerima snapshot event dan pet dari iPhone.
* Watch tetap dapat menampilkan snapshot terakhir ketika iPhone unreachable.
* Complete action dari Watch masuk ke outbox bila offline.
* Command diproses idempotent oleh iPhone.
* Setelah command sukses, Watch menerima snapshot authoritative terbaru.
* Sync failure menghasilkan state yang jelas.
* Unit test sync payload dan command processor lulus.

FASE 7 — APPLE WATCH COMPANION EXPERIENCE

Tujuan:

* Membuat Apple Watch menjadi companion produktivitas yang ringkas dan berguna.

Implementasi:

* Watch Now View.
* Watch Today View.
* Watch Event Detail View.
* Watch Pet View.
* Watch Settings View.
* Countdown event.
* Complete action.
* Skip action.
* Snooze action.
* Pending command state.
* Last sync indicator.
* Watch haptic feedback.
* Open on iPhone deep link.

Acceptance criteria:

* Watch menampilkan event aktif atau event berikutnya.
* Watch menampilkan agenda hari ini.
* Complete, skip, dan snooze menghasilkan command valid.
* Watch menampilkan pending state bila command belum acknowledged.
* Data stale ditampilkan secara jelas.
* Tidak ada full calendar monthly grid di Watch.
* UI dapat digunakan dengan satu tangan dan text scale besar.

FASE 8 — APPLE WATCH WIDGETS DAN COMPLICATIONS

Tujuan:

* Menyediakan akses agenda cepat dari watch face dan Smart Stack.

Implementasi:

* Next Event Complication.
* Pet Status Complication.
* Smart Stack widget.
* Timeline provider.
* Deep link ke WatchNowView.
* Empty state.
* Privacy mode.
* Reload strategy setelah snapshot baru diterima.

Acceptance criteria:

* Complication menampilkan event berikutnya atau pet status.
* Smart Stack menampilkan agenda relevan.
* Widget tidak crash bila Watch belum pernah tersinkronisasi.
* Privacy mode menyembunyikan judul event bila diaktifkan.
* Deep link bekerja.
* Timeline tidak mencoba update setiap detik.

FASE 9 — LIVE ACTIVITY AUTOMATION STRATEGY

Tujuan:

* Membuat Live Activity relevan tanpa bergantung pada perilaku background yang tidak stabil.

Implementasi:

* Evaluasi event saat app active.
* Refresh Live Activity saat app foreground.
* Start/update/end policy.
* Feature flag untuk capability iOS baru.
* Adapter untuk remote push Live Activity update di masa depan.
* Dokumentasikan limitasi local-only Live Activity.
* Trigger Watch snapshot refresh ketika event relevan berubah.

Acceptance criteria:

* Event relevan dipilih secara deterministik.
* Event aktif lebih prioritas daripada event upcoming.
* Live Activity tidak dibiarkan aktif setelah event selesai.
* Reminder tetap berjalan walau Live Activity tidak aktif.
* Watch menerima snapshot terbaru setelah state penting berubah.

FASE 10 — APPLE CALENDAR INTEGRATION

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
* Sinkronisasi perubahan relevan ke Apple Watch setelah import atau update.

Acceptance criteria:

* Pengguna dapat memilih calendar untuk diimpor.
* Tidak ada duplicate saat sync ulang.
* Permission denial tidak merusak calendar internal.
* Event internal tetap berfungsi tanpa EventKit.
* Watch hanya menerima snapshot event yang relevan.

FASE 11 — POLISH, WIDGETS, DAN QUALITY

Tujuan:

* Menyiapkan aplikasi untuk beta testing.

Implementasi:

* Home Screen widget iPhone.
* Lock Screen widget iPhone.
* Empty state lengkap.
* Onboarding.
* Settings.
* Localization.
* Accessibility audit.
* Performance profiling.
* UI test tambahan.
* Error logging.
* Backup/export plan untuk fase selanjutnya.
* Watch connectivity diagnostics screen.

Acceptance criteria:

* Widget iPhone menampilkan event berikutnya.
* Watch complication berfungsi.
* Dark mode berjalan.
* VoiceOver basic berjalan.
* Core flow memiliki UI test.
* Tidak ada crash pada empty state.
* Tidak ada hardcoded UI string.
* Sync diagnostics menjelaskan paired, reachable, stale, dan last sync status.

==================================================
23. TESTING REQUIREMENTS
========================

Buat test untuk:

General event:

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

Pet:

* Pet mood berdasarkan event terdekat.
* Pet XP setelah event selesai.
* Pet mood pada kondisi tanpa event.
* Pet mood saat event active.

Live Activity:

* Live Activity event selection.
* Fallback tanpa Dynamic Island.
* Deep link ke Event Detail.
* Event selesai menutup Live Activity.

Watch sync:

* Snapshot payload valid.
* Snapshot payload invalid.
* Snapshot version mismatch.
* Watch menerima application context terbaru.
* Watch command disimpan pada outbox bila iPhone tidak reachable.
* Watch command dikirim ulang setelah connection tersedia.
* Command duplikat tidak menjalankan action dua kali.
* Command acknowledged dihapus dari outbox.
* Event yang sudah dihapus tidak menyebabkan crash saat command diproses.
* Watch menampilkan stale data secara benar.
* Snapshot yang lebih lama tidak menggantikan snapshot yang lebih baru.
* Watch privacy mode menyembunyikan title event.
* Watch widget empty state.
* Watch complication deep link.

ViewModel:

* Loading state.
* Empty state.
* Error state.
* User action.
* Task cancellation bila relevan.
* Pending command state.
* Sync unavailable state.

Gunakan dependency injection untuk:

* Clock atau DateProvider.
* CalendarProvider.
* TimeZone.
* NotificationScheduler.
* EventRepository.
* LiveActivityManager.
* WatchSyncManager.
* WatchSessionManager.
* WatchCommandOutbox.
* Haptic service.

Jangan gunakan Date() langsung dalam business logic.

==================================================
24. CODING STANDARDS
====================

* Terapkan MVVM konsisten di setiap feature.
* ViewModel adalah satu-satunya presentation layer yang mengubah UI state.
* View tidak boleh memiliki business logic.
* View tidak boleh mengakses persistence layer atau service.
* Domain model tidak boleh bergantung pada SwiftUI, WidgetKit, ActivityKit, WatchKit, atau WatchConnectivity.
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
* Semua WatchConnectivity command harus idempotent.
* Semua sync payload harus versioned.
* Jangan menganggap Watch dan iPhone selalu reachable.
* Jangan membuat watchOS feature yang membutuhkan iPhone online secara terus-menerus.
* Jangan memasukkan data sensitif secara berlebihan ke complication atau widget.
* Optimalkan watchOS untuk battery life dan glanceable information.

==================================================
25. WORKING PROTOCOL
====================

Saat mulai bekerja:

1. Jangan membangun semua fase sekaligus.
2. Mulai hanya dari FASE 0.
3. Sebelum coding, tuliskan:

   * scope fase
   * file yang dibuat atau diubah
   * target yang terdampak: iOS, watchOS, widgets, atau shared package
   * asumsi teknis
   * test plan
4. Implementasikan fase tersebut.
5. Setelah implementasi, tampilkan:

   * ringkasan file yang dibuat atau diubah
   * target yang diubah
   * alasan keputusan arsitektur
   * cara menjalankan aplikasi iPhone
   * cara menjalankan Watch app
   * cara menjalankan test
   * known limitations
   * checklist acceptance criteria
6. Tunggu instruksi eksplisit “Lanjut Fase X” sebelum melanjutkan.
7. Jangan membuat backend, cloud sync, atau EventKit sync sebelum fase terkait.
8. Jika requirement tidak dapat dijalankan secara andal dalam lifecycle iOS atau watchOS, jelaskan limitasinya lalu implementasikan fallback paling stabil.
9. Prioritaskan aplikasi yang stabil, testable, maintainable, hemat baterai, dan buildable pada setiap fase.
10. Jangan mengubah struktur MVVM atau source-of-truth policy tanpa menjelaskan alasan teknisnya.
11. Jangan menganggap Apple Watch selalu paired, installed, reachable, atau memiliki data terbaru.
12. Gunakan simulator untuk UI dan unit test, tetapi dokumentasikan bahwa validasi penuh WatchConnectivity membutuhkan perangkat fisik yang paired.

Mulai sekarang hanya dengan FASE 0.
