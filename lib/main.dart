import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart'; 

// File baru untuk layout desktop

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintech Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Menggunakan Plus Jakarta Sans sesuai preferensi kamu
        textTheme: GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme),
        
        // WARNA UTAMA: Slate (Abu-Biru Gelap)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate 900
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF334155), // Slate 700
          surface: const Color(0xFFF8FAFC),   // Slate 50 (Background Terang)
        ),
        
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        
        // CARD STYLE: Minimalis & Shadow Lembut
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0, // Flat look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200), // Border tipis
          ),
        ),
        
        // APPBAR STYLE
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        ),

        // Scrollbar Theme untuk Desktop (Dari versi incoming)
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(Colors.grey.withOpacity(0.5)),
          thickness: WidgetStateProperty.all(8),
          radius: const Radius.circular(10),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}