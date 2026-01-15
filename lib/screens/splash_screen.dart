<<<<<<< HEAD
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_dashboard.dart'; // Pastikan import ini benar
=======
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'home_screen.dart';
import 'home_dashboard.dart';
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
<<<<<<< HEAD
  double _progressValue = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  // Logika Loading Bar Buatan Sendiri (Simulasi)
  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_progressValue < 1.0) {
          _progressValue += 0.01; // Kecepatan loading
        } else {
          _progressValue = 1.0;
          _timer?.cancel();
          _navigateToHome();
        }
      });
    });
  }

  void _navigateToHome() {
    // Beri jeda sedikit saat penuh 100% sebelum pindah
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeDashboard(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800), // Transisi halus
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate (Warna Premium)
      body: Stack(
        children: [
          // Dekorasi Background (Glow Halus di pojok)
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
             boxShadow: [
                BoxShadow(
          color: Colors.blue.withOpacity(0.1),
          blurRadius: 100, // blurRadius harus di sini
          spreadRadius: 50,
        ),
      ],
    ),
  ),
),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. LOGO ANIMASI
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(
                    Icons.candlestick_chart_rounded, 
                    size: 64, 
                    color: Color(0xFF38BDF8), // Light Blue Cyan
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack),

                const SizedBox(height: 30),

                // 2. TEXT JUDUL "MARKET ANALYZER"
                const Text(
                  "MARKET ANALYZER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900, // Sangat Tebal
                    letterSpacing: 4.0, // Spasi lebar biar elegan
                    fontFamily: 'Roboto', // Atau font pilihan Mas
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 10),

                // 3. SUBTITLE KECIL
                Text(
                  "Smart Portfolio & Investment Insight",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 50),

                // 4. CUSTOM LOADING BAR (GARIS BAWAH)
                SizedBox(
                  width: 200, // Lebar garis
                  child: Column(
                    children: [
                      // Bar Container
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1), // Track redup
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 30), // Smooth movement
                            height: 4,
                            width: 200 * _progressValue, // Lebar dinamis
                            decoration: BoxDecoration(
                              // Gradient Warna Loading
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF34D399)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 0),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Persentase Text (Opsional, kecil di bawah garis)
                      Text(
                        "${(_progressValue * 100).toInt()}%",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. FOOTER COPYRIGHT (Paling Bawah)
          Positioned(
            bottom: 30,
            left: 0, right: 0,
            child: Center(
              child: Text(
                "© 2026 Kanjeng Raden Mas Unan",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
=======
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        // Arahkan ke HomeDashboard
        MaterialPageRoute(builder: (_) => const HomeDashboard()), 
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Navy Background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO ICON
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.candlestick_chart_rounded, size: 80, color: Colors.white),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms, curve: Curves.easeInOut),
            
            const SizedBox(height: 32),
            
            // TEXT BRANDING
            const Text(
              "PORTFOLIO PRO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 8),
            
            Text(
              "Smart Investment Analysis",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ).animate().fadeIn(delay: 500.ms, duration: 800.ms),
          ],
        ),
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
      ),
    );
  }
}