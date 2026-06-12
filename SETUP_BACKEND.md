# 🚀 Panduan Setup Backend Nulisin (Supabase)

## Langkah 1 — Aktifkan Developer Mode Windows

Jalankan di PowerShell (sebagai Admin):
```powershell
start ms-settings:developers
```
Aktifkan "Developer Mode", lalu restart terminal.

---

## Langkah 2 — Buat Project Supabase

1. Buka **[supabase.com](https://supabase.com)** dan Login
2. Klik **"New Project"**
3. Isi:
   - **Name**: `nulisin`
   - **Database Password**: (simpan, akan dipakai nanti)
   - **Region**: Singapore (terdekat)
4. Tunggu project selesai dibuat (~2 menit)

---

## Langkah 3 — Jalankan SQL Migration

1. Di Supabase dashboard, buka **SQL Editor** (ikon database di sidebar)
2. Klik **"New Query"**
3. Copy-paste seluruh isi file `supabase_migration.sql` (ada di folder ini)
4. Klik **"Run"** (atau Ctrl+Enter)
5. Pastikan tidak ada error merah

---

## Langkah 4 — Setup Storage Buckets

Masih di SQL Editor, jalankan query berikut (atau bisa manual di Storage dashboard):

```sql
-- Bucket untuk foto profil
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);

-- Bucket untuk gambar sampul artikel
INSERT INTO storage.buckets (id, name, public) VALUES ('article-covers', 'article-covers', true);
```

Jika ada error "already exists", berarti sudah ada — lanjut saja.

---

## Langkah 5 — Ambil API Credentials

1. Di Supabase dashboard, buka **Settings** → **API**
2. Copy dua nilai:
   - **Project URL** → contoh: `https://abcdefgh.supabase.co`
   - **anon / public** key → string panjang yang dimulai dengan `eyJ...`

---

## Langkah 6 — Masukkan Credentials ke Flutter

Buka file: `lib/core/supabase_service.dart`

Cari bagian ini:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Ganti dengan credentials Anda:
```dart
static const String supabaseUrl = 'https://abcdefgh.supabase.co'; // ← URL project kamu
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // ← anon key kamu
```

---

## Langkah 7 — Nonaktifkan Email Confirmation (Development)

Agar bisa test tanpa konfirmasi email:

1. Buka **Authentication** → **Email Providers** di Supabase dashboard
2. Matikan **"Confirm email"** (toggle off)
3. Klik **Save**

---

## Langkah 8 — Jalankan Aplikasi

```bash
flutter pub get
flutter run
```

Atau jika mau run di web:
```bash
flutter run -d chrome
```

---

## Verifikasi Koneksi

Setelah login/register berhasil, cek di Supabase dashboard:
- **Authentication → Users** → user baru muncul
- **Table Editor → profiles** → profil terbuat otomatis (via trigger)
- **Table Editor → articles** → artikel baru setelah publish

---

## Struktur File yang Dibuat

```
lib/
├── core/
│   ├── supabase_service.dart  ← Service layer + Models (baru)
│   ├── router.dart            ← Auth guard (diupdate)
│   └── theme.dart             ← Tidak berubah
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         ← Supabase signIn (diupdate)
│   │   ├── register_screen.dart      ← Supabase signUp (diupdate)
│   │   └── complete_profile_screen.dart ← upsertProfile (diupdate)
│   └── main/
│       ├── home_screen.dart          ← Fetch articles (diupdate)
│       ├── explore_screen.dart       ← Fetch + filter (diupdate)
│       ├── profile_screen.dart       ← Real profile data (diupdate)
│       ├── edit_profile_screen.dart  ← Save to Supabase (diupdate)
│       ├── write_screen.dart         ← Publish to Supabase (diupdate)
│       └── article_detail_screen.dart ← Baru! Detail + komentar
└── main.dart                  ← Supabase.initialize (diupdate)
```

---

## Fitur yang Sudah Terhubung ke Supabase

| Fitur | Status |
|-------|--------|
| Register akun | ✅ |
| Login akun | ✅ |
| Logout | ✅ |
| Auth guard (proteksi halaman) | ✅ |
| Lengkapi profil | ✅ |
| Edit profil | ✅ |
| Discover feed (artikel terbaru) | ✅ |
| Filter per kategori | ✅ |
| Jelajahi topik (explore) | ✅ |
| Publish artikel | ✅ |
| Simpan draft | ✅ |
| Profil user (my stories + drafts) | ✅ |
| Detail artikel + komentar | ✅ |
| Kirim komentar | ✅ |
| Upload gambar (avatar/cover) | 🔲 UI siap, perlu image_picker integration |
