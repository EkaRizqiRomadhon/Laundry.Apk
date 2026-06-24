class Tarif {
  final int cuciSetrika;
  final int cuciKering;
  final int setrika;

  Tarif({
    this.cuciSetrika = 5000,
    this.cuciKering = 3500,
    this.setrika = 3500,
  });

  // Convert to Map
  Map<String, int> toMap() {
    return {
      'cuci_setrika': cuciSetrika,
      'cuci_kering': cuciKering,
      'setrika': setrika,
    };
  }

  // Convert from Map
  factory Tarif.fromMap(Map<String, int> map) {
    return Tarif(
      cuciSetrika: map['cuci_setrika'] ?? 5000,
      cuciKering: map['cuci_kering'] ?? 3500,
      setrika: map['setrika'] ?? 3500,
    );
  }

  // Get harga berdasarkan jenis laundry
  int getHargaByJenis(String jenis) {
    switch (jenis) {
      case 'Cuci + Setrika':
        return cuciSetrika;
      case 'Cuci Kering':
        return cuciKering;
      case 'Setrika':
        return setrika;
      default:
        return 0;
    }
  }

  // Copy with
  Tarif copyWith({
    int? cuciSetrika,
    int? cuciKering,
    int? setrika,
  }) {
    return Tarif(
      cuciSetrika: cuciSetrika ?? this.cuciSetrika,
      cuciKering: cuciKering ?? this.cuciKering,
      setrika: setrika ?? this.setrika,
    );
  }

  // Default tarif
  static Tarif defaultTarif() {
    return Tarif(
      cuciSetrika: 5000,
      cuciKering: 3500,
      setrika: 3500,
    );
  }
}
