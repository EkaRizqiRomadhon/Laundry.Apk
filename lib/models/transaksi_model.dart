class Transaksi {
  final int? id;
  final String namaPelanggan;
  final String tanggal;
  final String jenisLaundry;
  final double berat;
  final int hargaPerKg;
  final int total;
  final String createdAt;

  Transaksi({
    this.id,
    required this.namaPelanggan,
    required this.tanggal,
    required this.jenisLaundry,
    required this.berat,
    required this.hargaPerKg,
    required this.total,
    required this.createdAt,
  });

  // Convert Transaksi to Map (for database insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_pelanggan': namaPelanggan,
      'tanggal': tanggal,
      'jenis_laundry': jenisLaundry,
      'berat': berat,
      'harga_perkg': hargaPerKg,
      'total': total,
      'created_at': createdAt,
    };
  }

  // Convert Map to Transaksi
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'] as int?,
      namaPelanggan: map['nama_pelanggan'] as String,
      tanggal: map['tanggal'] as String,
      jenisLaundry: map['jenis_laundry'] as String,
      berat: (map['berat'] as num).toDouble(),
      hargaPerKg: map['harga_perkg'] as int,
      total: map['total'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  // Copy with - untuk update
  Transaksi copyWith({
    int? id,
    String? namaPelanggan,
    String? tanggal,
    String? jenisLaundry,
    double? berat,
    int? hargaPerKg,
    int? total,
    String? createdAt,
  }) {
    return Transaksi(
      id: id ?? this.id,
      namaPelanggan: namaPelanggan ?? this.namaPelanggan,
      tanggal: tanggal ?? this.tanggal,
      jenisLaundry: jenisLaundry ?? this.jenisLaundry,
      berat: berat ?? this.berat,
      hargaPerKg: hargaPerKg ?? this.hargaPerKg,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
