import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // --- DATA APLIKASI ---
  static const String _appName = "Fintech Portfolio Pro";
  static const String _appVersion = "v1.0.0 (Stable Release)";
  static const String _copyright = "© 2026 All Rights Reserved";


  static const List<Map<String, String>> _devTeam = [
    {
      'name': "Kanjeng Raden Mas Unan", 
      'role': "Lead Software Engineer",
      'initial': "KR"
    },
    {
      'name': "Muhammad Rifan", 
      'role': "Backend Logic",
      'initial': "D2"
    },
    {
      'name': "Ahmad Hadi Fauzan", 
      'role': "Backend Logic",
      'initial': "D3"
    },
    {
      'name': "Izzul Ahmad Fathoni", 
      'role': "UI/UX Designer",
      'initial': "D4"
    },
    {
      'name': "Mohammad Ludfi Rahmatullah", 
      'role': "Testing & QA",
      'initial': "D5"
    },
    {
      'name': "Fikriyandi Ikhsan", 
      'role': "Documentation",
      'initial': "D6"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // 1. LOGO APP
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.candlestick_chart_rounded, size: 40, color: Colors.white),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
              
              const SizedBox(height: 20),
              const Text(_appName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                child: const Text(_appVersion, style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 40),
              
              const Text("MEET THE TEAM", style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 16),

              // 2. LIST KARTU DEVELOPER (LOOPING)
              // Ini akan membuat kartu sebanyak jumlah developer di list _devTeam
              ..._devTeam.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> dev = entry.value;
                return _buildDevCard(dev['name']!, dev['role']!, dev['initial']!, index);
              }),

              const SizedBox(height: 40),

              // 3. COPYRIGHT FOOTER
              const Icon(Icons.verified_user_outlined, size: 20, color: Color(0xFF64748B)),
              const SizedBox(height: 8),
              const Text("Protected by copyright law.", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              const Text(_copyright, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET KARTU DEVELOPER
  Widget _buildDevCard(String name, String role, String initial, int index) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.only(bottom: 16), // Jarak antar kartu
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // Avatar Inisial
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initial, 
                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 18)
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Nama & Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans( // Atau font lain yg disuka
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          // Badge Check
          const Icon(Icons.verified, color: Colors.blue, size: 18),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0, delay: (100 * index).ms); // Animasi bertingkat
  }
}