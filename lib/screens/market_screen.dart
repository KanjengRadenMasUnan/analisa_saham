import 'dart:convert';
import 'dart:math'; // PENTING: Untuk min/max grafik
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../services/market_service.dart';
import 'stock_detail_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _service = MarketService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _allStocks = [];
  List<dynamic> _filteredStocks = [];
  bool _isLoadingJson = true;
  String _activeCategory = "All";

  // Cache IHSG
  late Future<List<double>> _ihsgChartFuture;
  late Future<Map<String, dynamic>> _ihsgPriceFuture;

  // Key untuk memaksa refresh widget
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

  // Fungsi Refresh Manual
  void _refreshAll() {
    setState(() {
      _isLoadingJson = true;
      _refreshKey = UniqueKey(); // Paksa rebuild widget
    });
    // Simulasi delay refresh
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
        _filterStocks(); // Re-apply filter jika ada search text
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
        child: CustomScrollView(
          controller: _scrollController,
          key: _refreshKey,
          slivers: [
            // 1. HEADER & SEARCH
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 2,
              pinned: true,
              floating: true,
              toolbarHeight: 80,
              title: Row(
                children: [
                  Expanded(
                    child: Container(
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshAll,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Refresh Harga"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),

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
                ),
              ),
            ),

            // 4. GRID SAHAM (MENAMPILKAN SEMUA - TANPA LIMIT)
            if (_searchController.text.isEmpty && _activeCategory == "All")
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: Text(
                    "Top Market Movers (Bluechip)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),

            // 5. GRID SAHAM (LIMIT 8)
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
                    childAspectRatio: 1.6, // Ratio kartu sedikit lebih tinggi
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

                          return _buildStockCard(data, stock['name']).animate().fadeIn(duration: 400.ms);
                        },
                      );
                    },
                    childCount: displayCount, // LIMIT LOGIC DISINI
                  ),
                ),
              ),
              
             const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
      ),
    );
  }

  Widget _buildIHSGHeader() {
    return Container(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> data, String stockName) {
    final ticker = data['symbol'];
    final price = data['price'] ?? 0.0;
    final changePct = data['changePercent'] ?? 0.0;
    final isUp = data['isUp'] ?? true;
    final color = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);

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
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200, highlightColor: Colors.white,
      child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
    );
  }
}