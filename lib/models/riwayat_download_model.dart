class RiwayatDownload {
  final int? id;
  final String namaFile;
  final String pathFile;
  final String tanggal;

  RiwayatDownload({
    this.id,
    required this.namaFile,
    required this.pathFile,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_file': namaFile,
      'path_file': pathFile,
      'tanggal': tanggal,
    };
  }

  factory RiwayatDownload.fromMap(Map<String, dynamic> map) {
    return RiwayatDownload(
      id: map['id'],
      namaFile: map['nama_file'],
      pathFile: map['path_file'],
      tanggal: map['tanggal'],
    );
  }
}
