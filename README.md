# 🚀 Nulisin — Premium Article Sharing Mobile Application

Nulisin adalah platform mobile berbasis literasi dan sastra premium yang dirancang untuk penulis dan pembaca. Aplikasi ini mengutamakan kenyamanan membaca dengan tipografi indah, transisi mulus, dan fitur sinkronisasi data yang cepat secara real-time.

---

## 🛠️ Technology Stack & Dependensi Utama

Proyek ini dibangun menggunakan kombinasi teknologi modern yang efisien dan andal:

### 1. Framework & Bahasa
*   **Flutter (Dart SDK ^3.11.1):** SDK utama untuk pengembangan aplikasi mobile multiplatform yang cepat dan responsif.

### 2. State Management (Native Approach)
*   **ValueNotifier & ValueListenableBuilder:** Digunakan sebagai pengelola state utama aplikasi (Single Source of Truth) dipadukan dengan pemanggilan `setState` lokal.
*   **Mengapa Memilih Native State?**
    *   **Performa Maksimal:** Hanya merender ulang widget yang mendengarkan (*leaf widgets*), meminimalkan beban CPU.
    *   **Hemat Memori:** Ukuran bundle aplikasi menjadi lebih kecil dan penggunaan RAM HP sangat rendah dibandingkan menggunakan package pihak ketiga seperti BLoC atau Riverpod.
    *   **Bebas Dependency Hell:** Bebas dari ancaman pembaruan package pihak ketiga yang sering kali merusak kompatibilitas kode (*breaking changes*).

### 3. Package Libraries (`pubspec.yaml`)
| Nama Package | Versi | Kegunaan Utama |
|---|---|---|
| `supabase_flutter` | `^2.8.4` | Penghubung utama ke Supabase (Database, Auth, Storage, Realtime). |
| `go_router` | `^14.6.3` | Navigasi deklaratif terintegrasi dengan Auth Guard (proteksi halaman login). |
| `google_fonts` | `^6.2.1` | Menggunakan font premium (Source Serif 4, Outfit, Inter) secara dinamis. |
| `shared_preferences` | `^2.3.2` | Menyimpan preferensi lokal dan konfigurasi offline cache dasar. |
| `image_picker` | `^1.1.2` | Memilih foto profil (avatar) dan foto sampul artikel dari galeri HP. |
| `cached_network_image` | `^3.4.1` | Caching gambar online untuk menghemat kuota data internet pengguna. |
| `flutter_markdown` | `^0.7.7+1` | Mem-parsing dan merender teks format Markdown di halaman detail artikel. |
| `flutter_quill` | `^11.5.0` | Editor teks kaya (*Rich Text Editor*) untuk kemudahan menulis artikel. |

---

## 📂 Arsitektur & Struktur Folder Proyek

Aplikasi Nulisin menerapkan pemisahan tugas (*separation of concerns*) yang terstruktur dalam direktori `lib/`:

```
lib/
├── core/
│   ├── theme.dart             ← Konfigurasi tema global, warna, tipografi, & input border
│   ├── router.dart            ← Sistem GoRouter & Auth Guards (proteksi akses)
│   └── supabase_service.dart  ← Singleton Database Service, Models, & State Notifier
├── screens/
│   ├── auth/                  ← Halaman login, register, dan complete profile
│   └── main/                  ← Halaman utama (Beranda, Jelajahi, Tulis, Simpan, Profil)
│       └── widgets/           ← Komponen kartu artikel dan penunjang antarmuka
└── main.dart                  ← Inisialisasi Supabase dan entry-point aplikasi
```

---

## 🗄️ Skema Database & RLS (Supabase)

Seluruh skema database ditulis secara deklaratif di dalam file `supabase_migration.sql`. Berikut adalah ringkasan struktur tabel:

1.  **`profiles`:** Menyimpan informasi biodata user. Otomatis terbuat sesaat setelah registrasi berkat PostgreSQL Trigger.
2.  **`categories`:** Menyimpan data kategori/topik tulisan.
3.  **`articles`:** Menyimpan artikel (termasuk status draft/publish, cover image url, dan hitungan `view_count`).
4.  **`article_categories`:** Tabel perantara (many-to-many) yang menghubungkan artikel dengan topik.
5.  **`comments`:** Menyimpan komentar pengguna pada artikel.
6.  **`bookmarks`:** Menyimpan ID artikel yang disimpan oleh pengguna.
7.  **`reading_history`:** Mencatat artikel yang sudah dibaca pengguna beserta waktu bacanya.

### Kebijakan Keamanan (Row Level Security - RLS):
*   **Profiles:** Publik dapat melihat profil siapa pun (`SELECT`), namun hanya pemilik akun yang dapat memperbaruinya (`UPDATE`).
*   **Articles:** Publik hanya dapat melihat artikel yang berstatus `is_published = true`. Penulis memiliki akses penuh CRUD atas artikel buatannya sendiri.
*   **Bookmarks & History:** Hanya pemilik akun yang diizinkan melihat, menambah, atau menghapus bookmark dan riwayat bacanya sendiri.

---

## 🚀 Panduan Setup Project dari Nol

Ikuti langkah-langkah berikut untuk menjalankan database Supabase dan aplikasi di laptop baru:

### Langkah 1 — Jalankan SQL Migration
1.  Buka dashboard **[supabase.com](https://supabase.com)**, login, dan buat project baru bernama `nulisin`.
2.  Masuk ke menu **SQL Editor** di sidebar kiri.
3.  Klik **"New Query"**, salin seluruh konten di file `supabase_migration.sql` dan tempelkan.
4.  Klik **"Run"** (atau Ctrl + Enter). Pastikan proses migrasi selesai tanpa pesan error.

### Langkah 2 — Ambil & Setel API Credentials
1.  Masuk ke menu **Settings** → **API** di dashboard Supabase.
2.  Salin nilai **Project URL** dan **anon / public** API Key.
3.  Buka file `lib/core/supabase_service.dart` di IDE Anda, lalu ganti nilai variabel berikut:
    ```dart
    static const String supabaseUrl = 'URL_SUPABASE_ANDA';
    static const String supabaseAnonKey = 'ANON_KEY_SUPABASE_ANDA';
    ```

### Langkah 3 — Nonaktifkan Verifikasi Email (Opsional - Development)
1.  Buka menu **Authentication** → **Email Providers** di dashboard Supabase.
2.  Matikan opsi **"Confirm email"** agar Anda bisa langsung login setelah registrasi tanpa membuka email konfirmasi.
3.  Klik **Save**.

### Langkah 4 — Jalankan Aplikasi
Jalankan perintah berikut pada terminal di folder proyek:
```bash
flutter pub get
flutter run
```
Untuk menguji di web (Chrome):
```bash
flutter run -d chrome
```

---

## 📈 Log Perjalanan & Milestones Pengembangan

### Minggu 1: UI Slicing & Navigasi Deklaratif
*   Mendesain UI premium untuk Landing Page, Login, Register, Beranda, Jelajahi, Tulis, Simpan, dan Profil.
*   Implementasi sistem navigasi modern menggunakan `GoRouter` dengan sistem perlindungan halaman (*Auth Guards*).

### Minggu 2: Integrasi Supabase Cloud & CRUD Dasar
*   Menghubungkan aplikasi ke layanan Database, Autentikasi, dan Buckets Storage milik Supabase.
*   Implementasi fitur registrasi, login, dan logout pengguna.
*   Mengaktifkan penulisan artikel dengan opsi Draft / Publish beserta fitur unggah foto sampul.

### Minggu 3: Fitur Sempurna, Realtime & Build Rilis
*   **Realtime Sync:** Integrasi Supabase Realtime Channel di halaman Beranda & Jelajahi untuk deteksi otomatis perubahan database secara instan (dilakukan dengan *Silent Update* latar belakang tanpa spinner mengganggu).
*   **Optimasi Halaman Bookmark:**
    *   Menerapkan desain datar transparan pada kolom pencarian (*no double-border*).
    *   Integrasi **Category Chips** dinamis (mengelompokkan bookmark berdasarkan topik aktif).
    *   Pencarian teks instan multi-kolom (mencocokkan judul, penulis, atau kategori).
*   **Pagination (Infinite Scroll):** Penerapan ScrollController untuk membatasi pemuatan awal (15 item) guna menghemat data internet dan RAM handphone.
*   **Validasi Topik Baru (2-State):** Topik kustom baru yang didaftarkan saat menulis draf tidak akan bocor ke halaman publik sebelum artikel bersangkutan resmi diterbitkan.
*   **Build APK:** Penyelesaian build rilis final di direktori `build/app/outputs/flutter-apk/app-release.apk` (61.7 MB).

---

## 👥 Panduan Kerja Tim (Git & GitHub Flow)

Demi menjaga keutuhan kode utama, seluruh anggota kelompok wajib menaati aturan kerja berikut:

### 1. Perbarui Kode Sebelum Mulai Bekerja
Setiap pagi atau sebelum mengetik kode baru, pastikan Anda menarik versi terbaru dari repositori online:
```bash
git checkout main
git pull origin main
```

### 2. Gunakan Branch Khusus
Jangan pernah menulis kode atau melakukan push langsung di branch `main`. Buatlah branch baru untuk tugas Anda:
```bash
git checkout -b nama-tugas-anda
```
*(Contoh: `git checkout -b slicing-login` atau `git checkout -b integrasi-komentar`)*

### 3. Simpan & Push Hasil Kerja
Setelah pekerjaan selesai atau mencapai progres harian yang stabil:
```bash
git add .
git commit -m "Tulis penjelasan singkat apa yang Anda ubah"
git push -u origin nama-tugas-anda
```

### 4. Buat Pull Request (PR)
1.  Buka repositori tim di GitHub lewat browser.
2.  Klik tombol **"Compare & pull request"** pada branch yang baru Anda push.
3.  Tulis deskripsi progres kerja Anda dan klik **"Create pull request"**.
4.  Kabari Ketua Kelompok/Admin di grup chat untuk meninjau, menyetujui (*Approve*), dan menyatukan (*Merge*) kode Anda ke branch `main`.
