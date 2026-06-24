import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarif_provider.dart';

class PengaturanTarifScreen extends StatefulWidget {
  const PengaturanTarifScreen({super.key});

  @override
  State<PengaturanTarifScreen> createState() => _PengaturanTarifScreenState();
}

class _PengaturanTarifScreenState extends State<PengaturanTarifScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _cuciSetrikaController;
  late TextEditingController _cuciKeringController;
  late TextEditingController _setrikaController;

  @override
  void initState() {
    super.initState();
    final tarifProvider = Provider.of<TarifProvider>(context, listen: false);
    _cuciSetrikaController = TextEditingController(text: tarifProvider.tarif.cuciSetrika.toString());
    _cuciKeringController = TextEditingController(text: tarifProvider.tarif.cuciKering.toString());
    _setrikaController = TextEditingController(text: tarifProvider.tarif.setrika.toString());
  }

  @override
  void dispose() {
    _cuciSetrikaController.dispose();
    _cuciKeringController.dispose();
    _setrikaController.dispose();
    super.dispose();
  }

  void _simpanTarif() async {
    if (_formKey.currentState!.validate()) {
      final tarifProvider = Provider.of<TarifProvider>(context, listen: false);
      
      await tarifProvider.updateTarif(
        cuciSetrika: int.parse(_cuciSetrikaController.text),
        cuciKering: int.parse(_cuciKeringController.text),
        setrika: int.parse(_setrikaController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarif berhasil diperbarui')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Tarif'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<TarifProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Atur harga per kilogram untuk masing-masing jenis layanan.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  
                  // Field Cuci + Setrika
                  TextFormField(
                    controller: _cuciSetrikaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tarif Cuci + Setrika (/Kg)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tarif tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Field Cuci Kering
                  TextFormField(
                    controller: _cuciKeringController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tarif Cuci Kering (/Kg)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tarif tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Field Setrika
                  TextFormField(
                    controller: _setrikaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tarif Setrika Saja (/Kg)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tarif tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _simpanTarif,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Simpan Tarif', style: TextStyle(fontSize: 16)),
                  ),
                  
                  TextButton(
                    onPressed: () async {
                      await provider.resetToDefault();
                      if (mounted) {
                        setState(() {
                          _cuciSetrikaController.text = provider.tarif.cuciSetrika.toString();
                          _cuciKeringController.text = provider.tarif.cuciKering.toString();
                          _setrikaController.text = provider.tarif.setrika.toString();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tarif dikembalikan ke default')),
                        );
                      }
                    },
                    child: const Text('Reset ke Default'),
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
