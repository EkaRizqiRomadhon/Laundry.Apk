import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaksi_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Laundry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<TransaksiProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Info Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Total Transaksi\nHari Ini',
                        provider.totalTransaksiHariIni.toString(),
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Pendapatan\nHari Ini',
                        currencyFormatter.format(provider.pendapatanHariIni),
                        Icons.payments,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // 5 Transaksi Terakhir
                const Text(
                  '5 Transaksi Terakhir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                if (provider.limaTerakhir.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('Belum ada transaksi hari ini')),
                  )
                else
                  ...provider.limaTerakhir.map((transaksi) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF0277BD).withOpacity(0.1),
                        foregroundColor: const Color(0xFF0277BD),
                        child: const Icon(Icons.person),
                      ),
                      title: Text(
                        transaksi.namaPelanggan, 
                        style: const TextStyle(fontWeight: FontWeight.w600)
                      ),
                      subtitle: Text(transaksi.jenisLaundry),
                      trailing: Text(
                        currencyFormatter.format(transaksi.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF0277BD),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      // Elevation dan rounded corners sudah diatur dari main.dart
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
