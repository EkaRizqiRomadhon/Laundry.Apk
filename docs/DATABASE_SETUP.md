# Database Setup Documentation

## Struktur Database

### Tabel: transaksi
```sql
CREATE TABLE transaksi (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama_pelanggan TEXT NOT NULL,
  tanggal TEXT NOT NULL,
  jenis_laundry TEXT NOT NULL,
  berat REAL NOT NULL,
  harga_perkg INTEGER NOT NULL,
  total INTEGER NOT NULL,
  created_at TEXT NOT NULL
)
```

## File Structure

```
lib/
├── models/
│   ├── transaksi_model.dart      # Model untuk transaksi
│   └── tarif_model.dart           # Model untuk tarif laundry
├── services/
│   ├── database_service.dart      # Service untuk SQLite
│   └── tarif_service.dart         # Service untuk mengelola tarif
└── main.dart
```

## Penggunaan Database Service

### 1. Inisialisasi Database (di main.dart)
```dart
import 'package:rizqi_laundy/services/database_service.dart';
import 'package:rizqi_laundy/services/tarif_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi TarifService
  await TarifService().init();
  
  runApp(const MyApp());
}
```

### 2. Membuat/Menambah Transaksi
```dart
import 'package:rizqi_laundy/models/transaksi_model.dart';
import 'package:rizqi_laundy/services/database_service.dart';

final db = DatabaseService();
final transaksi = Transaksi(
  namaPelanggan: 'Andi',
  tanggal: '2026-06-19',
  jenisLaundry: 'Cuci + Setrika',
  berat: 4.5,
  hargaPerKg: 5000,
  total: 22500,
  createdAt: DateTime.now().toIso8601String(),
);

int id = await db.addTransaksi(transaksi);
print('Transaksi ditambahkan dengan ID: $id');
```

### 3. Mengambil Semua Transaksi
```dart
List<Transaksi> semuaTransaksi = await db.getAllTransaksi();
for (var t in semuaTransaksi) {
  print('${t.namaPelanggan} - Rp${t.total}');
}
```

### 4. Mencari Transaksi (Realtime Search)
```dart
List<Transaksi> hasil = await db.searchTransaksiByNama('Andi');
for (var t in hasil) {
  print('${t.namaPelanggan} - ${t.jenisLaundry}');
}
```

### 5. Mengambil Transaksi per Tanggal
```dart
List<Transaksi> hariIni = await db.getTransaksiHariIni('2026-06-19');
int jumlah = hariIni.length;
print('Transaksi hari ini: $jumlah');
```

### 6. Mengambil Rekap (Range Tanggal)
```dart
List<Transaksi> rekap = await db.getTransaksiByDateRange(
  '2026-06-01',
  '2026-06-30',
);

int totalTransaksi = rekap.length;
double totalBerat = await db.getTotalBeratCucian('2026-06-01', '2026-06-30');
int totalPendapatan = await db.getTotalPendapatan(); // semua waktu

print('Total Transaksi: $totalTransaksi');
print('Total Berat: $totalBerat Kg');
print('Total Pendapatan: Rp$totalPendapatan');
```

### 7. Update Transaksi
```dart
final transaksiLama = await db.getTransaksiById(1);
if (transaksiLama != null) {
  final tranaksiBaru = transaksiLama.copyWith(
    berat: 5.0,
    total: 25000,
  );
  await db.updateTransaksi(tranaksiBaru);
}
```

### 8. Hapus Transaksi
```dart
await db.deleteTransaksi(1); // Hapus by ID
```

### 9. Ambil 5 Transaksi Terakhir (untuk Dashboard)
```dart
List<Transaksi> limaTerakhir = await db.getLastFiveTransaksi();
```

### 10. Summary untuk Dashboard
```dart
String tanggalHariIni = '2026-06-19';

int totalTransaksiHariIni = await db.getTotalTransaksiHariIni(tanggalHariIni);
int pendapatanHariIni = await db.getTotalPendapatanHariIni(tanggalHariIni);

print('Transaksi hari ini: $totalTransaksiHariIni');
print('Pendapatan hari ini: Rp$pendapatanHariIni');
```

## Penggunaan Tarif Service

### 1. Inisialisasi
```dart
import 'package:rizqi_laundy/services/tarif_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TarifService().init();
  runApp(const MyApp());
}
```

### 2. Mendapatkan Tarif
```dart
final tarifService = TarifService();
final tarif = await tarifService.getTarif();

print('Cuci + Setrika: Rp${tarif.cuciSetrika}');
print('Cuci Kering: Rp${tarif.cuciKering}');
print('Setrika: Rp${tarif.setrika}');
```

### 3. Mendapatkan Harga berdasarkan Jenis
```dart
final tarif = await tarifService.getTarif();
int harga = tarif.getHargaByJenis('Cuci + Setrika'); // 5000
```

### 4. Update Tarif
```dart
await tarifService.updateTarif(
  cuciSetrika: 6000,
  cuciKering: 4000,
  setrika: 4000,
);
```

### 5. Reset ke Default
```dart
await tarifService.resetToDefault();
```

## Contoh Perhitungan Otomatis

```dart
final tarif = await TarifService().getTarif();
final jenisLaundry = 'Cuci + Setrika';
final berat = 4.5;

final hargaPerKg = tarif.getHargaByJenis(jenisLaundry);
final total = (berat * hargaPerKg).toInt();

final transaksi = Transaksi(
  namaPelanggan: 'Andi',
  tanggal: '2026-06-19',
  jenisLaundry: jenisLaundry,
  berat: berat,
  hargaPerKg: hargaPerKg,
  total: total,
  createdAt: DateTime.now().toIso8601String(),
);

await DatabaseService().addTransaksi(transaksi);
```

## Notes

- Database file tersimpan di: `/data/local/tmp/laundry.db` (Android)
- Untuk production, perlu handle migration jika schema berubah
- Tarif disimpan di SharedPreferences untuk akses cepat
- Gunakan Provider untuk state management di UI
