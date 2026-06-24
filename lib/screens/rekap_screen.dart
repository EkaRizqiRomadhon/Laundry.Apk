import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaksi_provider.dart';
import '../models/transaksi_model.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';
import '../models/riwayat_download_model.dart';
import 'riwayat_download_screen.dart';

class SpinningIcon extends StatefulWidget {
  const SpinningIcon({super.key});

  @override
  State<SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<SpinningIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.sync, size: 48, color: Colors.blue),
    );
  }
}

class RekapScreen extends StatefulWidget {
  const RekapScreen({super.key});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Transaksi> _rekapData = [];
  bool _isLoading = false;

  void _pilihRangeTanggal() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadDataRekap();
    }
  }

  Future<void> _loadDataRekap() async {
    if (_startDate == null || _endDate == null) return;
    
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<TransaksiProvider>(context, listen: false);
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate!);

    final data = await provider.getRekap(startStr, endStr);

    setState(() {
      _rekapData = data;
      _isLoading = false;
    });
  }

  Future<void> _exportToExcel() async {
    if (_rekapData.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinningIcon(),
              SizedBox(height: 16),
              Text('Sedang membuat file Excel...', textAlign: TextAlign.center),
            ],
          ),
        ),
      );

      // Delay sedikit agar animasi memutar bisa terlihat
      await Future.delayed(const Duration(milliseconds: 1500));

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Header
      sheetObject.appendRow([
        TextCellValue('Tanggal'),
        TextCellValue('Nama Pelanggan'),
        TextCellValue('Jenis Laundry'),
        TextCellValue('Berat (Kg)'),
        TextCellValue('Harga/Kg'),
        TextCellValue('Total'),
      ]);

      // Data
      for (var t in _rekapData) {
        sheetObject.appendRow([
          TextCellValue(t.tanggal),
          TextCellValue(t.namaPelanggan),
          TextCellValue(t.jenisLaundry),
          DoubleCellValue(t.berat),
          IntCellValue(t.hargaPerKg),
          IntCellValue(t.total),
        ]);
      }

      var fileBytes = excel.save();
      final directory = await getTemporaryDirectory();
      
      final startStr = DateFormat('yyyy_MM_dd').format(_startDate!);
      final endStr = DateFormat('yyyy_MM_dd').format(_endDate!);
      final fileName = 'rekap_laundry_${startStr}_to_$endStr.xlsx';
      
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes!);

      // Save to Riwayat Download database
      final dbService = DatabaseService();
      await dbService.addRiwayatDownload(RiwayatDownload(
        namaFile: fileName,
        pathFile: file.path,
        tanggal: DateTime.now().toIso8601String(),
      ));

      Navigator.pop(context); // Tutup loading

      await Share.shareXFiles([XFile(file.path)], text: 'Rekap Transaksi Laundry');
    } catch (e) {
      Navigator.pop(context); // Tutup loading jika error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengekspor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Hitung ringkasan
    int totalTransaksi = _rekapData.length;
    double totalBerat = _rekapData.fold(0, (sum, item) => sum + item.berat);
    int totalPendapatan = _rekapData.fold(0, (sum, item) => sum + item.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekapitulasi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Download',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RiwayatDownloadScreen()),
              );
            },
          ),
          if (_rekapData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Export ke Excel',
              onPressed: _exportToExcel,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Filter Rentang Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                          : 'Pilih Tanggal',
                    ),
                    onPressed: _pilihRangeTanggal,
                  ),
                ],
              ),
            ),
          ),

          // Ringkasan Card
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryBox('Transaksi', totalTransaksi.toString(), Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryBox('Berat', '${totalBerat.toStringAsFixed(1)} Kg', Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryBox('Pendapatan', currencyFormatter.format(totalPendapatan), Colors.green),
                  ),
                ],
              ),
            ),
            
          const SizedBox(height: 16),

          // Daftar Data
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rekapData.isEmpty
                    ? const Center(child: Text('Pilih rentang tanggal untuk melihat data'))
                    : ListView.builder(
                        itemCount: _rekapData.length,
                        itemBuilder: (context, index) {
                          final t = _rekapData[index];
                          return ListTile(
                            leading: const Icon(Icons.receipt),
                            title: Text(t.namaPelanggan),
                            subtitle: Text('${t.tanggal} | ${t.jenisLaundry} | ${t.berat} Kg'),
                            trailing: Text(
                              currencyFormatter.format(t.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}
