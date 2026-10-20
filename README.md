# JUST JEJE ✏️

Aplikasi To-Do List & Randomizer Interaktif berbasis **Flutter** (Android, iOS, Web, Windows Desktop) dengan sinkronisasi real-time cloud menggunakan **Supabase Database**.

Dikonversi dari arsitektur React/Tauri ke **Flutter** dengan mempertahankan 100% desain visual, animasi, sistem tema kustom, dan seluruh logika aplikasinya.

---

## ✨ Fitur Utama

- **📝 To-Do List Cards & Task Management**:
  - Pengelompokan daftar tugas (Task Groups) dengan judul yang dapat diedit langsung (*inline editing*).
  - Custom checkbox modern dengan efek partikel konfeti perayaan saat tugas diselesaikan.
  - Tambah, ubah, dan hapus tugas secara instan.
  - Menu aksi 3-titik: Edit Teks, Simpan ke Bank Idea, dan Hapus.
- **🎲 Bank Idea & Randomize Generator**:
  - Kolam ide aktivitas (*Idea Pool*) dengan kategori (*Produktif, Anabul & Santai, Belajar, Olahraga, Tugas Rumah*).
  - Tombol **Generate** dengan efek acak slot-machine cepat yang memicu konfeti saat ide terpilih.
  - Pengiriman ide langsung dari Bank Idea ke To-Do Hari Ini.
- **☁️ Supabase Cloud Sync & Realtime**:
  - Sinkronisasi instan otomatis (debounced) dua arah.
  - Langganan WebSocket Postgres Changes secara real-time antar perangkat.
  - Modal pengaturan koneksi mandiri (Project URL & Anon Key) dan fitur pengujian koneksi.
- **🎨 7 Tema Estetik Lengkap**:
  - **Basic**: Kertas hangat & aksen biru elegan (`#4F5BD5`).
  - **Neat**: Monokrom rapi dan minimalis.
  - **Cute**: Pastel manis dengan motif canvas grid biru lembut.
  - **Picnic**: Nuansa taplak meja piknik kotak-kotak hangat bernuansa ceria.
  - **Mint Chocolate**: Mint segar dengan polkadot butiran cokelat.
  - **Dreamland** *(Dark)*: Lavender lembut dengan taburan bintang malam.
  - **Halloween** *(Dark)*: Nuansa gelap misterius dengan aksen oranye labu menyala.
  - Visual preview grid tema interaktif di halaman Pengaturan.
- **📄 Export to PDF**:
  - Ekspor dan cetak ringkasan daftar tugas ke format PDF secara rapi.
- **📱 Responsif & Multiplatform**:
  - Tampilan terpusat dengan canvas elegan di Desktop / Web, dan responsif penuh di Android & iOS.

---

## 🚀 Cara Menjalankan Aplikasi

Pastikan Flutter SDK sudah terpasang di komputer Anda.

### 1. Unduh Dependensi
```bash
flutter pub get
```

### 2. Jalankan di Chrome / Web
```bash
flutter run -d chrome
```

### 3. Jalankan di Windows Desktop
```bash
flutter run -d windows
```

### 4. Jalankan di Android Emulator / Perangkat
```bash
flutter run -d android
```

---

## 🗄️ Setup Database Supabase

Jika Anda menggunakan project Supabase baru:
1. Buka [Supabase Dashboard](https://supabase.com/dashboard).
2. Masuk ke **SQL Editor**.
3. Jalankan script SQL yang ada di file:
   ```
   supabase/schema.sql
   ```
4. Salin **Project URL** dan **Anon Key** dari menu *Project Settings > API*.
5. Masukkan ke dalam menu **Profil > Cloud Sync (Supabase Database)** di aplikasi.

---

## 📂 Struktur Proyek

```
lib/
├── main.dart                      # Entry point & state coordinator
├── models/
│   └── models.dart                # Data models (Task, TaskGroup, PoolItem, Configs)
├── services/
│   ├── storage_service.dart       # Local persistence (SharedPreferences)
│   ├── supabase_service.dart      # Supabase client, queries & realtime stream
│   └── pdf_service.dart           # Export to PDF generator & printer
├── theme/
│   ├── app_themes.dart            # 7 Theme definitions & Plus Jakarta Sans fonts
│   └── pattern_painters.dart      # CustomPainter untuk pattern background 60/120fps
├── views/
│   ├── dashboard_view.dart        # Halaman utama to-do list cards
│   ├── generate_view.dart         # Halaman Bank Idea & generator
│   └── settings_view.dart         # Halaman Profil, Tema, Cloud Sync, & Logout
└── widgets/
    ├── app_header.dart            # Header navigasi dengan tombol kotak bergaris
    ├── custom_scaffold.dart       # Scaffold responsif dengan confetti overlay
    ├── task_card.dart             # Card to-do list interaktif & tombol randomize
    └── modals/
        ├── add_idea_modal.dart    # Dialog tambah ide ke pool
        ├── add_list_modal.dart    # Dialog buat list baru
        ├── add_task_modal.dart    # Dialog tabbed tugas / list
        ├── google_modal.dart      # Dialog pengaturan Google Tasks
        └── supabase_modal.dart    # Dialog pengaturan Supabase Cloud Sync
```
