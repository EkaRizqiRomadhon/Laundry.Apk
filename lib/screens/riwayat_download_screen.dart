import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';
import '../models/riwayat_download_model.dart';
import 'package:intl/intl.dart';

class RiwayatDownloadScreen extends StatefulWidget {
  const RiwayatDownloadScreen({super.key});

  @override
  State<RiwayatDownloadScreen> createState() => _RiwayatDownloadScreenState();
}

class _RiwayatDownloadScreenState extends State<RiwayatDownloadScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<RiwayatDownload> _riwayatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoading = true);
    _riwayatList = await _dbService.getAllRiwayatDownload();
    setState(() => _isLoading = false);
  }

  void _shareFile(RiwayatDownload riwayat) async {
    final file = File(riwayat.pathFile);
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'File Rekap: ${riwayat.namaFile}');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File fisik sudah tidak ada atau terhapus')),
        );
      }
    }
  }

  void _hapusRiwayat(int id) async {
    await _dbService.deleteRiwayatDownload(id);
    _loadRiwayat();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Download'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _riwayatList.isEmpty
              ? const Center(child: Text('Belum ada riwayat download'))
              : ListView.builder(
                  itemCount: _riwayatList.length,
                  itemBuilder: (context, index) {
                    final riwayat = _riwayatList[index];
                    final dateObj = DateTime.parse(riwayat.tanggal);
                    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dateObj);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.description, color: Colors.green, size: 36),
                        title: Text(riwayat.namaFile, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(formattedDate),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.blue),
                              onPressed: () => _shareFile(riwayat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusRiwayat(riwayat.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
