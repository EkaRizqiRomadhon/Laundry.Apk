# PRD - Aplikasi Pencatatan Laundry

## 1. Informasi Produk

### Nama Aplikasi

Laundry App

### Platform

* Android
* Flutter
* Dart

### Database

* SQLite (Offline)

### Versi

1.0 (MVP)

---

# 2. Latar Belakang

Usaha laundry skala kecil umumnya masih menggunakan pencatatan manual sehingga sering terjadi kesalahan perhitungan biaya, kesulitan mencari data transaksi lama, dan kesulitan membuat rekap pemasukan.

Aplikasi ini dibuat untuk membantu proses pencatatan transaksi laundry secara digital dengan proses yang sederhana, cepat, dan mudah digunakan.

---

# 3. Tujuan Produk

Aplikasi harus mampu:

* Mencatat transaksi laundry.
* Menghitung biaya laundry otomatis.
* Menyimpan data transaksi.
* Melakukan pencarian berdasarkan nama pelanggan.
* Menampilkan rekap transaksi.
* Mengekspor rekap ke Excel/Spreadsheet.
* Berjalan secara offline.

---

# 4. Ruang Lingkup MVP

Fitur yang wajib tersedia pada versi pertama:

1. Dashboard
2. Tambah Transaksi
3. Daftar Transaksi
4. Pencarian Transaksi
5. Rekap Transaksi
6. Export Excel
7. Pengaturan Tarif

---

# 5. Tarif Laundry

| Jenis Laundry  | Harga      |
| -------------- | ---------- |
| Cuci + Setrika | Rp5.000/Kg |
| Cuci Kering    | Rp3.500/Kg |
| Setrika        | Rp3.500/Kg |

---

# 6. Struktur Menu

## Bottom Navigation

### Dashboard

Menampilkan ringkasan transaksi.

### Transaksi

Menampilkan daftar transaksi dan form tambah transaksi.

### Rekap

Menampilkan laporan dan export Excel.

### Pengaturan

Mengelola tarif laundry.

---

# 7. Dashboard

## Informasi yang Ditampilkan

* Total transaksi hari ini
* Total pendapatan hari ini
* 5 transaksi terakhir
* Tombol Tambah Transaksi

## Contoh Tampilan

Total Transaksi Hari Ini: 12

Pendapatan Hari Ini: Rp425.000

Transaksi Terakhir:

* Andi
* Budi
* Candra

---

# 8. Transaksi

## Form Input Transaksi

### Field

| Field          | Tipe     |
| -------------- | -------- |
| Nama Pelanggan | Text     |
| Tanggal        | Date     |
| Jenis Laundry  | Dropdown |
| Berat (Kg)     | Number   |
| Harga Per Kg   | Auto     |
| Total          | Auto     |

---

## Alur Perhitungan

### Cuci + Setrika

Harga = 5000

Contoh:

Berat = 4 Kg

Total = 4 × 5000

Total = Rp20.000

### Cuci Kering

Harga = 3500

Contoh:

Berat = 4 Kg

Total = 4 × 3500

Total = Rp14.000

### Setrika

Harga = 3500

Contoh:

Berat = 4 Kg

Total = 4 × 3500

Total = Rp14.000

---

## Validasi

* Nama pelanggan wajib diisi.
* Berat wajib lebih dari 0.
* Jenis laundry wajib dipilih.
* Tanggal wajib diisi.

---

# 9. Daftar Transaksi

## Data yang Ditampilkan

* Nama pelanggan
* Tanggal
* Jenis laundry
* Berat
* Total pembayaran

## Fitur

* Cari berdasarkan nama pelanggan
* Edit transaksi
* Hapus transaksi
* Urutkan berdasarkan tanggal terbaru

---

# 10. Pencarian

Pengguna dapat mencari transaksi berdasarkan nama pelanggan.

Contoh:

Input:

And

Hasil:

* Andi
* Andika
* Andri

Pencarian dilakukan secara realtime.

---

# 11. Rekap

## Filter

* Tanggal Awal
* Tanggal Akhir

## Data Rekap

| Tanggal | Nama | Jenis | Berat | Total |
| ------- | ---- | ----- | ----- | ----- |

## Ringkasan

Menampilkan:

* Jumlah transaksi
* Total berat cucian
* Total pendapatan

Contoh:

Jumlah Transaksi: 25

Total Berat: 80 Kg

Total Pendapatan: Rp1.850.000

---

# 12. Export Excel

## Tujuan

Menghasilkan laporan transaksi dalam format Excel.

## Nama File

rekap_laundry_YYYY_MM_DD.xlsx

Contoh:

rekap_laundry_2026_06_19.xlsx

## Kolom Excel

| Tanggal | Nama Pelanggan | Jenis Laundry | Berat | Harga/Kg | Total |
| ------- | -------------- | ------------- | ----- | -------- | ----- |

---

# 13. Pengaturan

## Tarif Laundry

Pengguna dapat mengubah:

* Tarif Cuci + Setrika
* Tarif Cuci Kering
* Tarif Setrika

Perubahan tarif digunakan untuk transaksi berikutnya.

---

# 14. Struktur Database

## Tabel transaksi

| Kolom          | Tipe                |
| -------------- | ------------------- |
| id             | INTEGER PRIMARY KEY |
| nama_pelanggan | TEXT                |
| tanggal        | TEXT                |
| jenis_laundry  | TEXT                |
| berat          | REAL                |
| harga_perkg    | INTEGER             |
| total          | INTEGER             |
| created_at     | TEXT                |

---

# 15. User Flow

Dashboard

↓

Tambah Transaksi

↓

Input Nama Pelanggan

↓

Pilih Tanggal

↓

Pilih Jenis Laundry

↓

Input Berat

↓

Total Dihitung Otomatis

↓

Simpan

↓

Masuk Daftar Transaksi

↓

Lihat Rekap

↓

Export Excel

---

# 16. Teknologi

## Flutter Packages

### Database

sqflite

### State Management

provider

### Export Excel

excel

### File Storage

path_provider

### Share File

share_plus

### Format Rupiah

intl

---

# 17. Non Functional Requirements

* Aplikasi berjalan tanpa internet.
* Data tersimpan secara lokal.
* Perhitungan dilakukan secara realtime.
* Waktu respon kurang dari 1 detik.
* UI sederhana dan mudah digunakan.
* Mendukung export Excel.
* Mendukung pencarian data secara cepat.

---

# 18. Future Enhancement

Versi berikutnya dapat menambahkan:

* Status cucian (Diproses, Dicuci, Disetrika, Selesai)
* Status pembayaran
* Cetak struk Bluetooth
* Backup dan Restore database
* Sinkronisasi cloud
* Grafik pendapatan
* Multi-user

