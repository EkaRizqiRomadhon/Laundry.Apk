import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Menunggu 3 detik sebelum pindah halaman
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    // Pindah ke MainScreen dan hapus SplashScreen dari tumpukan (history)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Menampilkan Logo
            Container(
              width: 164,
              height: 164,
              padding: const EdgeInsets.all(4), // Jarak antara foto dan garis (opsional, agar lebih manis)
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0277BD).withOpacity(0.4), // Warna stroke tipis
                  width: 2.0, // Ketebalan stroke
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo_laundry.jpg',
                  width: 156,
                  height: 156,
                  fit: BoxFit.cover,
                  // Jika gambar tidak ditemukan
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.local_laundry_service, 
                      size: 80, 
                      color: Color(0xFF0277BD),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Nama Aplikasi
            const Text(
              'Rizqi Laundry',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0277BD),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bersih, Wangi, & Rapi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const Spacer(),
            
            // Loading muter (Circular Progress Indicator)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0277BD)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 48), // Jarak dari bawah
          ],
        ),
      ),
    );
  }
}
