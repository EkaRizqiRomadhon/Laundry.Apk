import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/tarif_model.dart';

class TarifService {
  static final TarifService _instance = TarifService._internal();
  static SharedPreferences? _prefs;

  factory TarifService() {
    return _instance;
  }

  TarifService._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Initialize default tarif jika belum ada
    if (!_prefs!.containsKey('tarif')) {
      await saveTarif(Tarif.defaultTarif());
    }
  }

  Future<void> saveTarif(Tarif tarif) async {
    await _prefs!.setString('tarif', jsonEncode(tarif.toMap()));
  }

  Future<Tarif> getTarif() async {
    final tarifJson = _prefs!.getString('tarif');
    if (tarifJson == null) {
      return Tarif.defaultTarif();
    }
    return Tarif.fromMap(Map<String, int>.from(jsonDecode(tarifJson)));
  }

  Future<void> updateTarif({
    int? cuciSetrika,
    int? cuciKering,
    int? setrika,
  }) async {
    final currentTarif = await getTarif();
    final updatedTarif = currentTarif.copyWith(
      cuciSetrika: cuciSetrika,
      cuciKering: cuciKering,
      setrika: setrika,
    );
    await saveTarif(updatedTarif);
  }

  Future<void> resetToDefault() async {
    await saveTarif(Tarif.defaultTarif());
  }
}
