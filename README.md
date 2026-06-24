# PawPlan (Pet Calendar)

PawPlan adalah aplikasi kalender dan penjadwalan pribadi (*personal planner*) dengan *virtual pet* sebagai asisten visual. Pet akan bereaksi terhadap jadwal Anda, memberikan konteks visual untuk agenda terdekat, serta terintegrasi secara kontekstual di iPhone dan Apple Watch companion.

---

## 🏗️ Arsitektur & Teknologi

Aplikasi ini menggunakan pola **Feature-First MVVM** dengan pemisahan modul yang ketat:
- **PawPlan (iOS)**: Aplikasi utama (source of truth data).
- **PawPlan Watch App (watchOS)**: Aplikasi pendamping (companion app) untuk melacak agenda hari ini secara cepat.
- **Packages/PawPlanShared**: Local Swift Package yang menyimpan domain model, aturan bisnis, protokol, dan data transfer payload.

### Stack Teknologi:
- **iOS 17.0+** & **watchOS 10.0+**
- **SwiftUI** & **SwiftData** (penyimpanan lokal berkelanjutan)
- **WatchConnectivity** (sinkronisasi iPhone dan Apple Watch)
- **WidgetKit** & **ActivityKit** (Live Activities & Dynamic Island)

---

## 📂 Struktur Proyek

```
PawPlan/
├── Packages/
│   └── PawPlanShared/         # Shared Swift Package (Domain, Rules, Sync Models)
├── PawPlan/                   # Target Aplikasi iOS (MVVM Features, App Container)
├── PawPlan Watch App/         # Target Aplikasi watchOS (Now View, Today, Pet Status)
└── PawPlanTests/              # Target Unit Testing
```

---

## ⚙️ Cara Menjalankan Proyek

1. **Konfigurasi Target Xcode**:
   Buka terminal di root proyek ini dan jalankan skrip pembantu untuk mendaftarkan target unit test di Xcode:
   ```bash
   ruby setup_project.rb
   ```
2. **Impor Shared Package**:
   Buka `PawPlan.xcodeproj` di Xcode. Drag and drop folder `Packages/PawPlanShared` ke dalam proyek Anda di Xcode (di bawah root group) untuk menautkannya secara lokal. Tautkan library `PawPlanShared` pada tab **Frameworks, Libraries, and Embedded Content** di bawah target *PawPlan* dan *PawPlan Watch App*.
3. **Build & Run**:
   Pilih skema **PawPlan** (untuk iPhone Simulator/Device) atau **PawPlan Watch App** (untuk Apple Watch Simulator) dan tekan **Cmd + R**.

---

## 🧪 Pengujian (Unit Testing)

Untuk menjalankan unit test:
1. Pilih skema **PawPlan** di Xcode.
2. Tekan **Cmd + U** di keyboard Anda untuk menjalankan semua tes di `PawPlanTests` dan `PawPlanSharedTests`.
