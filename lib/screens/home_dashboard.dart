import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart'; // Pastikan package ini ada
import 'market_screen.dart';
import 'portfolio_screen.dart';
import 'news_screen.dart';
import 'about_screen.dart';
=======
import 'market_screen.dart';
import 'portfolio_screen.dart';
import 'news_screen.dart';
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const MarketScreen(),
    const PortfolioScreen(),
    const NewsScreen(),
<<<<<<< HEAD
    const AboutScreen(),
=======
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
  ];

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // Deteksi Ukuran Layar
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    // --- TAMPILAN DESKTOP (SIDEBAR) ---
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
              backgroundColor: Colors.white,
              elevation: 1,
              extended: width > 1200, // Lebar otomatis jika layar besar
              minWidth: 80,
              labelType: width > 1200 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              // Logo Header Sidebar
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.candlestick_chart_rounded, size: 28, color: Colors.white),
                ),
              ),
              // Styling Icon Desktop
              selectedIconTheme: const IconThemeData(color: Color(0xFF0F172A), size: 28),
              unselectedIconTheme: IconThemeData(color: Colors.grey.shade400),
              selectedLabelTextStyle: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
              
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.show_chart_rounded), label: Text('Market')),
                NavigationRailDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart_rounded), label: Text('Portfolio')),
                NavigationRailDestination(icon: Icon(Icons.newspaper_outlined), selectedIcon: Icon(Icons.newspaper_rounded), label: Text('News')),
                NavigationRailDestination(icon: Icon(Icons.info_outline_rounded), selectedIcon: Icon(Icons.info_rounded), label: Text('About')),
              ],
            ),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      );
    } 
    
    // --- TAMPILAN MOBILE (FLOATING NAV BAR) ---
    else {
      return Scaffold(
        // extendBody: true membuat konten bisa discroll sampai ke balik navbar (efek transparan)
        extendBody: true, 
        body: _pages[_selectedIndex],
        
        // CONTAINER PEMBUNGKUS BAR
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // Jarak dari pinggir & bawah
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), // Sudut Melengkung Modern
              boxShadow: [
                // Bayangan Super Halus (Soft Shadow)
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFF0F172A), // Warna Pil Aktif (Dark Slate)
                  elevation: 0,
                  height: 70,
                  // Style Label Teks
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return GoogleFonts.plusJakartaSans( // Gunakan Font Modern
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF0F172A)
                      );
                    }
                    return GoogleFonts.plusJakartaSans(
                      fontSize: 12, 
                      fontWeight: FontWeight.w500, 
                      color: Colors.grey.shade500
                    );
                  }),
                  // Style Icon
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: Colors.white, size: 26); // Icon Aktif Putih
                    }
                    return IconThemeData(color: Colors.grey.shade400, size: 26); // Icon Pasif Abu
                  }),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // Label selalu muncul agar UX jelas
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.candlestick_chart_outlined), 
                      selectedIcon: Icon(Icons.candlestick_chart_rounded), 
                      label: 'Market'
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.pie_chart_outline), 
                      selectedIcon: Icon(Icons.pie_chart_rounded), 
                      label: 'Holdings' // Ganti "Portfolio" jadi "Holdings" biar pendek & pas
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.newspaper_outlined), 
                      selectedIcon: Icon(Icons.newspaper_rounded), 
                      label: 'News'
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.info_outline_rounded), 
                      selectedIcon: Icon(Icons.info_rounded), 
                      label: 'About'
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
=======
    return Scaffold(
      body: Row(
        children: [
          // 1. SIDEBAR NAVIGATION (Desktop Style)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 5,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(Icons.candlestick_chart_rounded, size: 40, color: Theme.of(context).primaryColor),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.show_chart_rounded),
                selectedIcon: Icon(Icons.show_chart, fill: 1),
                label: Text('Market'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pie_chart_outline),
                selectedIcon: Icon(Icons.pie_chart),
                label: Text('Portfolio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.newspaper_outlined),
                selectedIcon: Icon(Icons.newspaper),
                label: Text('Berita'),
              ),
            ],
          ),
          
          const VerticalDivider(thickness: 1, width: 1),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
  }
}