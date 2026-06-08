# 🚀 Panduan Git & GitHub dari Nol (Untuk Pemula)

Halo! Ini adalah panduan super lengkap dari nol agar kita bisa kerja kelompok menggunakan Git dan GitHub tanpa pusing dan tanpa takut kode kita rusak atau saling menimpa.

---

## 🛠️ LANGKAH 1: PERSIAPAN AWAL (Cukup Sekali Saja)

Sebelum mulai koding, kamu harus memasang dan menyetel Git di laptopmu terlebih dahulu.

### 1. Download & Install Git
*   **Pengguna Windows**: Download Git Bash di [git-scm.com](https://git-scm.com) dan install seperti biasa (klik Next sampai selesai).
*   **Pengguna Mac**: Buka Terminal, ketik `git --version`, dan ikuti petunjuk pasang jika belum ada.

### 2. Daftarkan Identitas Akunmu
Buka Git Bash (Windows) atau Terminal (Mac), lalu ketik dua perintah di bawah ini secara bergantian (Ganti dengan nama dan email GitHub-mu sendiri):
```bash
git config --global user.name "Nama Lengkapmu"
git config --global user.email "email_githubmu@example.com"
```

### 3. Clone (Unduh) Proyek Kelompok Kita
Masuk ke folder tempat kamu biasa menyimpan tugas di laptopmu lewat terminal, lalu jalankan perintah ini untuk mengunduh folder proyek kita dari GitHub:
```bash
git clone https://github.com
```
Setelah selesai, masuk ke dalam folder proyek tersebut:
```bash
cd nama-repo-kita
```

---

## 📌 3 ATURAN EMAS KELOMPOK (WAJIB DIINGAT!)
1. **Jangan Pernah** mengetik kode atau melakukan `git push` langsung saat berada di branch `main` (Akses sudah dikunci oleh Admin).
2. **Wajib Buat Branch Baru** untuk setiap tugas masing-masing (misal: `frontend`, `backend`, `fitur-login`).
3. **Wajib `git pull`** di pagi hari sebelum mulai koding agar file di laptopmu selalu sama dengan versi terbaru milik tim.

---

## 💻 LANGKAH 2: ALUR KERJA HARIAN (SAAT KODING)

Ikuti urutan perintah ini setiap kali kamu mau mulai mengerjakan tugas baru:

### 1. Ambil Pembaruan Terkini dari Tim
Pastikan kodemu tidak ketinggalan zaman dengan menarik file terbaru dari branch utama:
```bash
git checkout main
git pull origin main
```

### 2. Buat & Pindah ke Branch Tugasmu
Buat branch baru sesuai bagian yang kamu kerjakan (ganti `nama-branch-mu` dengan nama tugasmu, misal: `backend`):
```bash
git checkout -b nama-branch-mu
```

### 3. Silakan Koding di VS Code
Buka VS Code, lalu ketik kodinganmu sampai selesai atau sampai berprogres.

### 4. Simpan Hasil Kerja ke Komputer Lokal
Jika kodingan sudah selesai dan mau disimpan ke dalam riwayat catatan komputer lokalmu, ketik secara berurutan:
```bash
git status
git add .
git commit -m "Tulis penjelasan apa yang kamu ubah/tambah"
```

### 5. Kirim ke GitHub
Kirim branch beserta hasil kerjamu ke server GitHub kelompok kita. **(Khusus push pertama kali di branch baru, jalankan perintah ini):**
```bash
git push -u origin nama-branch-mu
```
*(Untuk push kedua, ketiga, dan seterusnya di branch yang sama, kamu cukup mengetik singkat `git push` saja).*

---

## 🌐 LANGKAH 3: MEMINTA KETUA MEMASUKKAN KODEMU KE MAIN

Setelah kamu sukses melakukan `git push`, kodinganmu belum langsung menyatu ke branch utama proyek (`main`). Kamu harus meminta izin review ke Ketua/Admin lewat web GitHub:

1. Buka halaman web repositori proyek kita di browser (Chrome/Edge/Safari).
2. GitHub akan otomatis memunculkan kotak kuning/hijau di bagian atas bertuliskan **"Compare & pull request"**. Klik tombol tersebut.
3. Tulis judul dan deskripsi singkat (contoh: *"Halo ketua, fitur database backend sudah selesai, tolong diperiksa"*).
4. Klik tombol **Create pull request**.
5. **Selesai!** Beritahu Ketua/Admin di grup WhatsApp/Discord untuk memeriksa, melakukan *Approve*, dan melakukan *Merge* kodinganmu ke branch `main`.

---

*💡 Tips Darurat: Jika terminalmu tiba-earth terasa macet atau terkunci teks panjang saat mengetik perintah git log, cukup tekan tombol **`q`** di keyboard untuk keluar.*
