import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarif_provider.dart';
import '../providers/transaksi_provider.dart';
import '../models/transaksi_model.dart';
import 'package:intl/intl.dart';

class TambahTransaksiScreen extends StatefulWidget {
  final Transaksi? transaksi;
  const TambahTransaksiScreen({super.key, this.transaksi});

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _beratController = TextEditingController();
  final _hargaCustomController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedJenis = 'Cuci + Setrika';
  
  final List<String> _jenisLaundryOptions = [
    'Cuci + Setrika',
    'Cuci Kering',
    'Setrika',
    'Custom (Satuan)'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transaksi != null) {
      _namaController.text = widget.transaksi!.namaPelanggan;
      _beratController.text = widget.transaksi!.berat.toString();
      _selectedDate = DateTime.parse(widget.transaksi!.tanggal);
      _selectedJenis = widget.transaksi!.jenisLaundry;
      
      if (_selectedJenis == 'Custom (Satuan)') {
        _hargaCustomController.text = widget.transaksi!.hargaPerKg.toString();
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _beratController.dispose();
    _hargaCustomController.dispose();
    super.dispose();
  }

  void _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  int _hitungTotal(int hargaPerKg) {
    if (_beratController.text.isEmpty) return 0;
    double? berat = double.tryParse(_beratController.text);
    if (berat == null) return 0;
    
    if (_selectedJenis == 'Custom (Satuan)') {
      int? hargaCustom = int.tryParse(_hargaCustomController.text);
      if (hargaCustom == null) return 0;
      return (berat * hargaCustom).toInt();
    }
    return (berat * hargaPerKg).toInt();
  }

  void _simpanTransaksi(int hargaPerKg) async {
    if (_formKey.currentState!.validate()) {
      final berat = double.parse(_beratController.text);
      int finalHargaPerKg = hargaPerKg;
      
      if (_selectedJenis == 'Custom (Satuan)') {
        finalHargaPerKg = int.parse(_hargaCustomController.text);
      }
      
      final total = (berat * finalHargaPerKg).toInt();
      
      final transaksi = Transaksi(
        id: widget.transaksi?.id,
        namaPelanggan: _namaController.text,
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate),
        jenisLaundry: _selectedJenis,
        berat: berat,
        hargaPerKg: finalHargaPerKg,
        total: total,
        createdAt: widget.transaksi?.createdAt ?? DateTime.now().toIso8601String(),
      );

      final provider = Provider.of<TransaksiProvider>(context, listen: false);
      if (widget.transaksi != null) {
        await provider.updateTransaksi(transaksi);
      } else {
        await provider.addTransaksi(transaksi);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.transaksi != null ? 'Transaksi berhasil diupdate' : 'Transaksi berhasil ditambahkan')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider untuk mendapatkan tarif realtime
    final tarifProvider = context.watch<TarifProvider>();
    final hargaPerKg = tarifProvider.tarif.getHargaByJenis(_selectedJenis);
    
    // Format mata uang rupiah
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaksi != null ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: tarifProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Nama
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pelanggan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pilih Tanggal
                InkWell(
                  onTap: () => _pilihTanggal(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Transaksi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pilih Jenis Laundry
                DropdownButtonFormField<String>(
                  value: _selectedJenis,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Laundry',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_laundry_service),
                  ),
                  items: _jenisLaundryOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedJenis = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Input Berat / Jumlah
                TextFormField(
                  controller: _beratController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _selectedJenis == 'Custom (Satuan)' ? 'Jumlah (Pcs)' : 'Berat Cucian',
                    suffixText: _selectedJenis == 'Custom (Satuan)' ? 'Pcs' : 'Kg',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(_selectedJenis == 'Custom (Satuan)' ? Icons.shopping_bag : Icons.scale),
                    helperText: _selectedJenis == 'Custom (Satuan)' 
                        ? null 
                        : 'Harga per Kg: ${currencyFormatter.format(hargaPerKg)}',
                  ),
                  onChanged: (value) {
                    setState(() {}); // Memicu re-build untuk update auto-calculate Total
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _selectedJenis == 'Custom (Satuan)' ? 'Jumlah tidak boleh kosong' : 'Berat tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Masukkan angka yang valid (> 0)';
                    }
                    return null;
                  },
                ),
                if (_selectedJenis == 'Custom (Satuan)') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hargaCustomController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Satuan (Rp)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Masukkan harga yang valid (> 0)';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),

                // Auto Calculate Info Card
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Total Estimasi Biaya',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(_hitungTotal(hargaPerKg)),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: () => _simpanTransaksi(hargaPerKg),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
