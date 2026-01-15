import 'package:flutter/material.dart';
import 'portfolio_screen.dart';
import 'market_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MarketScreen(),    // Halaman Utama: Market
    const PortfolioScreen(), // Halaman Tools: Portfolio
    const NewsScreen(),      // Halaman Info: Berita
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Pakai IndexedStack agar halaman tidak reload saat pindah tab
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          indicatorColor: const Color(0xFF0F172A).withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            _buildNavItem(Icons.show_chart_rounded, Icons.show_chart, 'Market'),
            _buildNavItem(Icons.pie_chart_outline, Icons.pie_chart, 'Portfolio'),
            _buildNavItem(Icons.newspaper_outlined, Icons.newspaper, 'Berita'),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildNavItem(IconData icon, IconData selectedIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon, color: Colors.grey.shade500),
      selectedIcon: Icon(selectedIcon, color: const Color(0xFF0F172A)),
      label: label,
    );
  }
}