import 'dart:convert';
<<<<<<< HEAD
import 'dart:math'; // PENTING: Untuk min/max grafik
=======
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../services/market_service.dart';
import 'stock_detail_screen.dart';
<<<<<<< HEAD
=======
import 'dart:math';
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _service = MarketService();
  final TextEditingController _searchController = TextEditingController();
<<<<<<< HEAD
  final ScrollController _scrollController = ScrollController();
=======
  final ScrollController _scrollController = ScrollController(); // Untuk Scrollbar
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9

  List<dynamic> _allStocks = [];
  List<dynamic> _filteredStocks = [];
  bool _isLoadingJson = true;
  String _activeCategory = "All";

  // Cache IHSG
  late Future<List<double>> _ihsgChartFuture;
  late Future<Map<String, dynamic>> _ihsgPriceFuture;

<<<<<<< HEAD
  // Key untuk memaksa refresh widget
=======
  // Variabel untuk trigger refresh
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterStocks);
  }

  void _loadData() {
    _loadStocksFromJson();
    setState(() {
      _ihsgChartFuture = _service.getChartData("IHSG");
      _ihsgPriceFuture = _service.getStockPrice("IHSG");
    });
  }

<<<<<<< HEAD
  void _refreshAll() {
    setState(() {
      _isLoadingJson = true;
      _refreshKey = UniqueKey();
    });
=======
  // Fungsi Refresh Manual
  void _refreshAll() {
    setState(() {
      _isLoadingJson = true;
      _refreshKey = UniqueKey(); // Paksa rebuild widget
    });
    // Simulasi delay refresh
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
    Future.delayed(const Duration(milliseconds: 800), () {
      _loadData();
    });
  }

  Future<void> _loadStocksFromJson() async {
    try {
      final String response = await rootBundle.loadString('assets/stocks.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _allStocks = data;
        _filteredStocks = data;
<<<<<<< HEAD
        _filterStocks(); 
=======
        _filterStocks(); // Re-apply filter jika ada search text
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
        _isLoadingJson = false;
      });
    } catch (e) {
      debugPrint("Error loading JSON: $e");
    }
  }

  void _filterStocks() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStocks = _allStocks.where((stock) {
        String symbol = stock['symbol'].toString().toLowerCase();
        String name = stock['name'].toString().toLowerCase();
        
        bool matchesSearch = symbol.contains(query) || name.contains(query);
        bool matchesCategory = true;

        if (_activeCategory == "Banking") {
          matchesCategory = symbol.startsWith("B") && symbol.length == 4;
        } else if (_activeCategory == "Tech") {
          matchesCategory = ["GOTO", "BUKA", "EMTK", "DMMX", "ARTO"].contains(stock['symbol']);
        } else if (_activeCategory == "Energy") {
          matchesCategory = ["ADRO", "PTBA", "ITMG", "PGAS", "MEDC", "MDKA"].contains(stock['symbol']);
        }
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _setActiveCategory(String category) {
    setState(() {
      _activeCategory = category;
      _filterStocks();
    });
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // 1. RESPONSIVE GRID CONFIG
    final width = MediaQuery.of(context).size.width;
    // Desktop (>1100): 4 Kolom, Tablet: 3, Mobile: 2
    int gridCount = width > 1100 ? 4 : (width > 600 ? 3 : 2); 

    // 2. LOGIKA LIMIT TAMPILAN (Clean UI)
    int displayCount = _filteredStocks.length;
    // Hanya batasi jika tidak sedang mencari DAN kategori All
    if (_searchController.text.isEmpty && _activeCategory == "All") {
       if (displayCount > 8) displayCount = 8;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: width > 800, // Scrollbar hanya di Desktop
=======
    // Responsive Grid Count: Desktop = 4, Tablet = 2
    final width = MediaQuery.of(context).size.width;
    int gridCount = width > 1100 ? 4 : (width > 700 ? 3 : 2);
    int displayCount = _filteredStocks.length;
    if (_searchController.text.isEmpty && _activeCategory == "All") {
       if (displayCount > 8) {
         displayCount = 8;
       }
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
        child: CustomScrollView(
          controller: _scrollController,
          key: _refreshKey,
          slivers: [
<<<<<<< HEAD
            // --- HEADER SEARCH & REFRESH ---
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
=======
            // 1. HEADER & SEARCH
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 2,
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
              pinned: true,
              floating: true,
              toolbarHeight: 80,
              title: Row(
                children: [
                  Expanded(
                    child: Container(
<<<<<<< HEAD
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Cari Emiten (cth: BUMI, GOTO...)",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
=======
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Cari Emiten lain (ketik: BUMI, GOTO...)", // Hint lebih jelas
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
<<<<<<< HEAD
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _refreshAll,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: "Refresh Harga",
=======
                  ElevatedButton.icon(
                    onPressed: _refreshAll,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Refresh Harga"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
                    ),
                  ),
                ],
              ),
            ),

<<<<<<< HEAD
            // --- IHSG DASHBOARD (PREMIUM STYLE) ---
            SliverToBoxAdapter(child: _buildIHSGHeader()),

            // --- FILTER CHIPS ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("All"),
                      _buildFilterChip("Banking"),
                      _buildFilterChip("Energy"),
                      _buildFilterChip("Tech"),
                    ],
                  ),
=======
            // 2. DASHBOARD IHSG
            SliverToBoxAdapter(child: _buildIHSGHeader()),

            // 3. FILTER CHIPS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    _buildFilterChip("All"),
                    _buildFilterChip("Banking"),
                    _buildFilterChip("Energy"),
                    _buildFilterChip("Tech"),
                  ],
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
                ),
              ),
            ),

<<<<<<< HEAD
            // --- SECTION TITLE ---
=======
            // 4. GRID SAHAM (MENAMPILKAN SEMUA - TANPA LIMIT)
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
            if (_searchController.text.isEmpty && _activeCategory == "All")
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: Text(
                    "Top Market Movers (Bluechip)",
<<<<<<< HEAD
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey, letterSpacing: 1),
=======
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
                  ),
                ),
              ),

<<<<<<< HEAD
            // --- GRID SAHAM ---
=======
            // 5. GRID SAHAM (LIMIT 8)
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
            if (_isLoadingJson)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_filteredStocks.isEmpty)
              const SliverFillRemaining(child: Center(child: Text("Emiten tidak ditemukan")))
            else
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
<<<<<<< HEAD
                    childAspectRatio: 1.6, // Ratio kartu sedikit lebih tinggi
=======
                    childAspectRatio: 1.8,
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final stock = _filteredStocks[index];
                      return FutureBuilder<Map<String, dynamic>>(
                        future: _service.getStockPrice(stock['symbol']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return _buildShimmerCard();
                          final data = snapshot.data ?? {};
                          if (data.isEmpty) return _buildShimmerCard();

<<<<<<< HEAD
                          return _buildStockCard(data, stock['name']).animate().fadeIn(duration: 400.ms);
                        },
                      );
                    },
                    childCount: displayCount, // LIMIT LOGIC DISINI
=======
                          return _buildStockCard(data, stock['name']).animate().fadeIn();
                        },
                      );
                    },
                    childCount: displayCount, // <--- INI KUNCINYA (Pakai displayCount yg sudah di-limit)
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
                  ),
                ),
              ),
              
<<<<<<< HEAD
             const SliverToBoxAdapter(child: SizedBox(height: 100)),
=======
             const SliverToBoxAdapter(child: SizedBox(height: 50)),
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildFilterChip(String label) {
    bool isActive = _activeCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => _setActiveCategory(label),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF0F172A),
<<<<<<< HEAD
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: BorderSide(color: isActive ? Colors.transparent : Colors.grey.shade200)
        ),
        showCheckmark: false,
        elevation: 0,
=======
        labelStyle: TextStyle(color: isActive ? Colors.white : Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
        showCheckmark: false,
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
      ),
    );
  }

  Widget _buildIHSGHeader() {
    return Container(
<<<<<<< HEAD
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      height: 230,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF334155)], // Slate Gradient
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("MARKET OVERVIEW", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("IHSG Composite", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Row(children: [Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFF34D399)), SizedBox(width: 6), Text("REALTIME", style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold))]),
                    )
                  ],
                ),
                const Spacer(),
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _ihsgPriceFuture,
                        builder: (context, snapshot) {
                          final data = snapshot.data ?? {};
                          final price = data['price'] ?? 0.0;
                          final changePct = data['changePercent'] ?? 0.0;
                          final isUp = data['isUp'] ?? true;
                          final color = isUp ? const Color(0xFF34D399) : const Color(0xFFF87171); // Soft Green/Red

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(NumberFormat('#,###.##').format(price), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                              Row(children: [
                                Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: color, size: 18),
                                const SizedBox(width: 4),
                                Text("${changePct.toStringAsFixed(2)}%", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                              ]),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: FutureBuilder<List<double>>(
                          future: _ihsgChartFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final data = snapshot.data!;
                            // Gunakan library math import 'dart:math';
                            double minY = data.reduce(min);
                            double maxY = data.reduce(max);
                            return LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineTouchData: const LineTouchData(enabled: false),
                                minY: minY * 0.999,
                                maxY: maxY * 1.001,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: true,
                                    color: Colors.white,
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.white.withOpacity(0.2), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
=======
      height: 250,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          // Kiri: Info Text
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("MARKET OVERVIEW", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("IHSG Composite", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                FutureBuilder<Map<String, dynamic>>(
                  future: _ihsgPriceFuture,
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? {};
                    final price = data['price'] ?? 0.0;
                    final changePct = data['changePercent'] ?? 0.0;
                    final isUp = data['isUp'] ?? true;
                    final color = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                    
                    if(snapshot.connectionState == ConnectionState.waiting) return const SizedBox();

                    return Row(
                      children: [
                        Text(NumberFormat('#,###.##').format(price), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text("${isUp ? '+' : ''}${changePct.toStringAsFixed(2)}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Kanan: Chart
          Expanded(
            flex: 2,
            child: FutureBuilder<List<double>>(
              future: _ihsgChartFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
                final data = snapshot.data!;
                double minY = data.reduce(min);
                double maxY = data.reduce(max);

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (maxY - minY)/3),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: minY * 0.999,
                    maxY: maxY * 1.001,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: const Color(0xFF38BDF8),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF38BDF8).withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                      ),
                    ],
                  ),
                );
              },
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
=======
  // CARD SAHAM (GRID STYLE)
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
  Widget _buildStockCard(Map<String, dynamic> data, String stockName) {
    final ticker = data['symbol'];
    final price = data['price'] ?? 0.0;
    final changePct = data['changePercent'] ?? 0.0;
    final isUp = data['isUp'] ?? true;
    final color = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);

<<<<<<< HEAD
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Premium Soft Shadow
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StockDetailScreen(ticker: ticker, currentData: data)));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 45, height: 45,
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(ticker[0], style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 18))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticker, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(stockName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Rp ${NumberFormat('#,###').format(price)}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text("${isUp ? '+' : ''}${changePct.toStringAsFixed(2)}%", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                )
              ],
            ),
=======
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => StockDetailScreen(ticker: ticker, currentData: data)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Text(ticker, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  ),
                  Icon(isUp ? Icons.trending_up : Icons.trending_down, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(stockName, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Rp ${NumberFormat('#,###').format(price)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${isUp ? '+' : ''}${changePct.toStringAsFixed(2)}%", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              // Mini Chart
              SizedBox(
                height: 30,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(10, (i) => FlSpot(i.toDouble(), isUp ? i.toDouble() : 10 - i.toDouble())),
                        isCurved: true,
                        color: color.withOpacity(0.5),
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      )
                    ],
                  ),
                ),
              ),
            ],
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200, highlightColor: Colors.white,
<<<<<<< HEAD
      child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
=======
      child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
    );
  }
}