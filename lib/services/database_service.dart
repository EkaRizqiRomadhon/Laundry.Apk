import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaksi_model.dart';
import '../models/riwayat_download_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'rizqi_laundry.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
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
    ''');
    
    await db.execute('''
      CREATE TABLE riwayat_download (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_file TEXT NOT NULL,
        path_file TEXT NOT NULL,
        tanggal TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE riwayat_download (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_file TEXT NOT NULL,
          path_file TEXT NOT NULL,
          tanggal TEXT NOT NULL
        )
      ''');
    }
  }

  // CREATE - Tambah transaksi
  Future<int> addTransaksi(Transaksi transaksi) async {
    final db = await database;
    return await db.insert('transaksi', transaksi.toMap());
  }

  // READ - Ambil semua transaksi
  Future<List<Transaksi>> getAllTransaksi() async {
    final db = await database;
    final maps = await db.query(
      'transaksi',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Transaksi.fromMap(maps[i]));
  }

  // READ - Ambil transaksi by ID
  Future<Transaksi?> getTransaksiById(int id) async {
    final db = await database;
    final maps = await db.query(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Transaksi.fromMap(maps.first);
  }

  // READ - Cari transaksi by nama pelanggan (realtime search)
  Future<List<Transaksi>> searchTransaksiByNama(String nama) async {
    final db = await database;
    final maps = await db.query(
      'transaksi',
      where: 'nama_pelanggan LIKE ?',
      whereArgs: ['%$nama%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Transaksi.fromMap(maps[i]));
  }

  // READ - Ambil transaksi by date range (untuk rekap)
  Future<List<Transaksi>> getTransaksiByDateRange(
    String tanggalAwal,
    String tanggalAkhir,
  ) async {
    final db = await database;
    final maps = await db.query(
      'transaksi',
      where: 'tanggal BETWEEN ? AND ?',
      whereArgs: [tanggalAwal, tanggalAkhir],
      orderBy: 'tanggal DESC',
    );

    return List.generate(maps.length, (i) => Transaksi.fromMap(maps[i]));
  }

  // READ - Ambil transaksi hari ini
  Future<List<Transaksi>> getTransaksiHariIni(String tanggalHariIni) async {
    final db = await database;
    final maps = await db.query(
      'transaksi',
      where: 'tanggal = ?',
      whereArgs: [tanggalHariIni],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Transaksi.fromMap(maps[i]));
  }

  // UPDATE - Update transaksi
  Future<int> updateTransaksi(Transaksi transaksi) async {
    final db = await database;
    return await db.update(
      'transaksi',
      transaksi.toMap(),
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  // DELETE - Hapus transaksi
  Future<int> deleteTransaksi(int id) async {
    final db = await database;
    return await db.delete(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Hapus semua transaksi (reset database)
  Future<int> deleteAllTransaksi() async {
    final db = await database;
    return await db.delete('transaksi');
  }

  // SUMMARY - Total transaksi
  Future<int> getTotalTransaksi() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM transaksi');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // SUMMARY - Total transaksi hari ini
  Future<int> getTotalTransaksiHariIni(String tanggalHariIni) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transaksi WHERE tanggal = ?',
      [tanggalHariIni],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // SUMMARY - Total pendapatan
  Future<int> getTotalPendapatan() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT SUM(total) as total FROM transaksi');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // SUMMARY - Total pendapatan hari ini
  Future<int> getTotalPendapatanHariIni(String tanggalHariIni) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM transaksi WHERE tanggal = ?',
      [tanggalHariIni],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // SUMMARY - Total berat cucian (dalam range tanggal)
  Future<double> getTotalBeratCucian(
    String tanggalAwal,
    String tanggalAkhir,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(berat) as total FROM transaksi WHERE tanggal BETWEEN ? AND ?',
      [tanggalAwal, tanggalAkhir],
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  // SUMMARY - 5 transaksi terakhir (untuk dashboard)
  Future<List<Transaksi>> getLastFiveTransaksi() async {
    final db = await database;
    final maps = await db.query(
      'transaksi',
      orderBy: 'created_at DESC',
      limit: 5,
    );

    return List.generate(maps.length, (i) => Transaksi.fromMap(maps[i]));
  }

  // RIWAYAT DOWNLOAD - Tambah
  Future<int> addRiwayatDownload(RiwayatDownload riwayat) async {
    final db = await database;
    return await db.insert('riwayat_download', riwayat.toMap());
  }

  // RIWAYAT DOWNLOAD - Ambil semua
  Future<List<RiwayatDownload>> getAllRiwayatDownload() async {
    final db = await database;
    final maps = await db.query(
      'riwayat_download',
      orderBy: 'tanggal DESC',
    );
    return List.generate(maps.length, (i) => RiwayatDownload.fromMap(maps[i]));
  }

  // RIWAYAT DOWNLOAD - Delete
  Future<int> deleteRiwayatDownload(int id) async {
    final db = await database;
    return await db.delete(
      'riwayat_download',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
