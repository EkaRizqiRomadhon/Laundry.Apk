# Rizqi Laundry App 🧺

Aplikasi Kasir dan Manajemen Pencatatan Laundry offline berbasis **Flutter** dan **SQLite**. Dibangun dengan antarmuka yang bersih, performa super cepat tanpa perlu internet, dan dilengkapi fitur-fitur krusial yang memudahkan operasional bisnis laundry skala kecil hingga menengah.

## ✨ Fitur Utama
* **Pencatatan Transaksi Fleksibel**: Mendukung hitungan per kilogram (Cuci Kering, Setrika, Cuci+Setrika) maupun harga custom/satuan (seperti selimut, gorden, atau karpet).
* **Auto-Calculate Total**: Perhitungan harga otomatis secara seketika berdasarkan input berat/jumlah dan tarif layanan.
* **Dashboard Monitoring**: Pantau ringkasan jumlah transaksi dan pendapatan kotor harian langsung dari beranda.
* **Riwayat & Pencarian Instan**: Melacak histori transaksi pelanggan dengan mudah berkat fitur *Live Search*, serta kemampuan *Edit* dan *Delete*.
* **Rekapitulasi Kalender**: Filter riwayat transaksi berdasarkan rentang tanggal tertentu (*Start Date* hingga *End Date*) untuk mengkalkulasi omset mingguan/bulanan.
* **Export ke Excel (.xlsx)**: Mengonversi data rekap transaksi ke dalam file Excel dan dapat dibagikan langsung ke WhatsApp/Email. Dilengkapi dengan **Halaman Riwayat Download** untuk melihat ulang file yang pernah diekspor.
* **Database Lokal (Offline)**: Menggunakan SQLite. Data pelanggan tersimpan secara eksklusif dan 100% aman di dalam perangkat, tanpa memerlukan biaya server atau kuota internet.

## 🛠️ Teknologi yang Digunakan
* **Framework**: Flutter (Dart)
* **State Management**: Provider
* **Database**: `sqflite` (SQLite)
* **Pencetakan Laporan**: `excel`, `path_provider`, `share_plus`
* **Formatting & UI**: `intl`, Material 3 Design

## 🚀 Cara Menjalankan Project (Local Development)

1. **Clone Repository**
   ```bash
   git clone https://github.com/EkaRizqiRomadhon/Laundry.Apk.git
   ```
2. **Masuk ke Direktori Proyek**
   ```bash
   cd Laundry.Apk
   ```
3. **Unduh Dependencies**
   ```bash
   flutter pub get
   ```
4. **Jalankan Aplikasi**
   Pastikan *emulator* atau perangkat *smartphone* Anda sudah terhubung (Cek dengan `flutter devices`).
   ```bash
   flutter run
   ```

## 🔒 Catatan Keamanan
Repositori ini telah dikonfigurasi melalui `.gitignore` untuk **memblokir** berkas `.db`, `.sqlite`, dan `.jks`. Hal ini bertujuan murni untuk melindungi kerahasiaan data *real* pelanggan dan *key signing* aplikasi dari publikasi yang tidak disengaja. Apabila Anda menjalankan *project* ini di perangkat baru untuk pertama kali, sistem akan secara mandiri mengkonstruksi struktur *database* yang utuh dari nol.

---
*Dikembangkan oleh Eka Rizqi Romadhon untuk mendukung digitalisasi operasional Rizqi Laundry.*
