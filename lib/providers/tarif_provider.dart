import 'package:flutter/material.dart';
import '../models/tarif_model.dart';
import '../services/tarif_service.dart';

class TarifProvider extends ChangeNotifier {
  final TarifService _tarifService = TarifService();
  
  Tarif _tarif = Tarif.defaultTarif();
  Tarif get tarif => _tarif;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  TarifProvider() {
    _loadTarif();
  }

  Future<void> _loadTarif() async {
    _isLoading = true;
    notifyListeners();
    
    _tarif = await _tarifService.getTarif();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTarif({
    int? cuciSetrika,
    int? cuciKering,
    int? setrika,
  }) async {
    await _tarifService.updateTarif(
      cuciSetrika: cuciSetrika,
      cuciKering: cuciKering,
      setrika: setrika,
    );
    await _loadTarif(); // Reload tarif after updating
  }

  Future<void> resetToDefault() async {
    await _tarifService.resetToDefault();
    await _loadTarif();
  }
}
