# Nulisin — Online Publishing Platform

Nulisin adalah platform penerbitan daring berbasis mobile yang dirancang untuk menyederhanakan proses penulisan dan pembacaan artikel digital secara terstruktur. Aplikasi ini memecahkan kompleksitas teknis blogging konvensional dengan menghadirkan antarmuka editorial minimalis, kenyamanan membaca yang optimal, dan sinkronisasi konten secara real-time.

---

## 👥 Pemilik Proyek (Project Owners)
Proyek ini dikembangkan oleh kelompok mahasiswa **Pemrograman Mobile — ITG 2026**:

| Nama Lengkap | NIM |
|---|---|
| **Vidya Tiara Eka Putri** | 2306005 |
| **Bambang Surya Prana** | 2306013 |
| **Naufal Kalam Marudi** | 2306021 |

---

## 🛠️ Tech Stack & Dependensi

*   **Frontend Framework**: Flutter & Dart (SDK `^3.11.1`) dengan Native State Management (`ValueNotifier`).
*   **Backend (BaaS)**: Supabase Cloud (Autentikasi, PostgreSQL Database, Realtime Sync, & File Storage).
*   **Paket Dependensi**: `supabase_flutter`, `go_router`, `flutter_quill` (Rich Text Editor), `cached_network_image`, `flutter_markdown_plus`, `shared_preferences`, `connectivity_plus`.

---

## ✨ Fitur Utama

*   **Autentikasi Akun**: Registrasi & login (Supabase Auth) dengan opsi pengisian data profil lengkap (foto & bio).
*   **CRUD Artikel**: Tulis, edit, dan hapus artikel (Draft/Publish) lengkap dengan unggah gambar sampul.
*   **Feed & Detail Artikel**: Feed artikel terurut kronologis dengan penyaringan kategori dan layout baca yang nyaman.
*   **Komentar**: Kolom diskusi kronologis bagi pengguna terautentikasi untuk berinteraksi di bawah artikel.
*   **Bookmark**: Simpan artikel favorit untuk dibaca nanti.

---

## 📱 Uji Coba Produk Akhir (Instan)

Jika Anda hanya ingin langsung mencoba/menguji produk akhir tanpa melakukan setup kode sumber dan database, silakan unduh dan pasang berkas APK Nulisin melalui tautan berikut:
👉 **[Download APK Nulisin (Google Drive)](https://drive.google.com/drive/folders/1HvIAk08j3AZBUZd1qG7U7OrTtMRwC0K4?usp=sharing)**

---

## ⚙️ Cara Menjalankan Proyek Secara Lokal (Development)

Untuk menjalankan proyek ini dari kode sumber secara lokal, Anda perlu menyiapkan backend dan database sendiri menggunakan Supabase (BaaS).

### 1. Prasyarat
Pastikan perangkat Anda telah terpasang:
*   Flutter SDK (>= 3.11.1) & Dart SDK
*   Android Studio / VS Code beserta extension Flutter & Dart
*   Emulator Android atau Google Chrome (untuk Web)
*   Akun aktif di [Supabase](https://supabase.com)

### 2. Langkah Instalasi & Setup

#### Langkah A: Clone & Ambil Dependensi
```bash
git clone https://github.com/solHeathcliff/Nulisin.git
cd "Aplikasi Nulisin"
flutter pub get
```

#### Langkah B: Setup Database Supabase
1.  Buat proyek baru di dashboard **[Supabase](https://supabase.com)**.
2.  Buka menu **SQL Editor**, salin dan jalankan seluruh query dalam berkas `supabase_migration.sql`.
3.  Buat dua bucket dengan akses **Public** pada menu **Storage**: `avatars` dan `article-covers`.
4.  Matikan opsi **Confirm email** pada menu **Authentication** -> **Providers** -> **Email** agar pendaftaran akun dapat langsung dicoba tanpa verifikasi email.

#### Langkah C: Konfigurasi Kredensial di Kode Sumber
1.  Salin **Project URL** dan **anon public API Key** dari menu **Settings → API** di dashboard Supabase Anda.
2.  Buka berkas `lib/core/supabase_service.dart` di proyek lokal Anda, lalu ganti nilai variabel berikut:
    ```dart
    static const String supabaseUrl = 'URL_SUPABASE_ANDA';
    static const String supabaseAnonKey = 'ANON_KEY_SUPABASE_ANDA';
    ```

#### Langkah D: Jalankan Proyek
Jalankan perintah berikut di terminal Anda:
```bash
# Jalankan di Google Chrome (Web)
flutter run -d chrome

# Jalankan di Emulator / Perangkat Android
flutter run
```

---

## 📖 Cara Penggunaan (Alur Kerja)

```mermaid
flowchart TD
    A([Mulai]) --> B[Landing Page & Login/Daftar]
    B --> C[Lengkapi Profil Foto & Bio]
    C --> D[Beranda & Jelajahi Kategori]
    D --> E[Baca Artikel & Beri Komentar]
    D --> F[Tulis Artikel Editor Teks + Cover]
    F --> G[Terbitkan / Simpan Draft]
    D --> H[Simpan ke Bookmark Offline]
```