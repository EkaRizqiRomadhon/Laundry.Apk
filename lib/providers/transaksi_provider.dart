import 'package:flutter/material.dart';
import '../models/transaksi_model.dart';
import '../services/database_service.dart';

class TransaksiProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<Transaksi> _semuaTransaksi = [];
  List<Transaksi> get semuaTransaksi => _semuaTransaksi;

  List<Transaksi> _limaTerakhir = [];
  List<Transaksi> get limaTerakhir => _limaTerakhir;

  int _totalTransaksiHariIni = 0;
  int get totalTransaksiHariIni => _totalTransaksiHariIni;

  int _pendapatanHariIni = 0;
  int get pendapatanHariIni => _pendapatanHariIni;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  TransaksiProvider() {
    refreshData();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    await _loadSemuaTransaksi();
    await _loadDashboardData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSemuaTransaksi() async {
    _semuaTransaksi = await _dbService.getAllTransaksi();
  }

  Future<void> _loadDashboardData() async {
    final todayStr = _formatDate(DateTime.now());
    
    _limaTerakhir = await _dbService.getLastFiveTransaksi();
    _totalTransaksiHariIni = await _dbService.getTotalTransaksiHariIni(todayStr);
    _pendapatanHariIni = await _dbService.getTotalPendapatanHariIni(todayStr);
  }

  Future<void> addTransaksi(Transaksi transaksi) async {
    await _dbService.addTransaksi(transaksi);
    await refreshData();
  }

  Future<void> updateTransaksi(Transaksi transaksi) async {
    await _dbService.updateTransaksi(transaksi);
    await refreshData();
  }

  Future<void> deleteTransaksi(int id) async {
    await _dbService.deleteTransaksi(id);
    await refreshData();
  }

  Future<void> searchTransaksi(String query) async {
    _isLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      await _loadSemuaTransaksi();
    } else {
      _semuaTransaksi = await _dbService.searchTransaksiByNama(query);
    }

    _isLoading = false;
    notifyListeners();
  }
  
  Future<List<Transaksi>> getRekap(String startDate, String endDate) async {
    return await _dbService.getTransaksiByDateRange(startDate, endDate);
  }
  
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
