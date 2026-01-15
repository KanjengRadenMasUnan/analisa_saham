import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import 'news_detail_screen.dart'; // Kita akan buat file ini setelah ini

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _service = NewsService();
  
  // State
  String _selectedRegion = "ID"; // Default Indonesia
  late Future<List<Article>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
    setState(() {
      _newsFuture = _service.fetchNews(_selectedRegion);
    });
  }

  // Ganti Region
  void _changeRegion(String region) {
    if (_selectedRegion == region) return;
    setState(() {
      _selectedRegion = region;
      _loadNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Grid
    final width = MediaQuery.of(context).size.width;
    int gridCount = width > 1100 ? 3 : (width > 700 ? 2 : 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Global Market News"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadNews, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          // 1. REGION TABS (PILIHAN NEGARA)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRegionTab("Indonesia", "ID", "🇮🇩"),
                  _buildRegionTab("United States", "US", "🇺🇸"),
                  _buildRegionTab("China", "CN", "🇨🇳"),
                  _buildRegionTab("European Union", "EU", "🇪🇺"),
                ],
              ),
            ),
          ),
          
          // 2. DAFTAR BERITA (GRID)
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return _buildLoadingGrid(gridCount);
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.public_off, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text("Tidak ada berita untuk wilayah $_selectedRegion", style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                final articles = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
                    childAspectRatio: 0.8, // Aspect Ratio
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return _buildNewsCard(articles[index])
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.1, end: 0, delay: (50 * index).ms);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildRegionTab(String label, String code, String flag) {
    bool isActive = _selectedRegion == code;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _changeRegion(code),
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0F172A) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isActive ? const Color(0xFF0F172A) : Colors.grey.shade300),
            boxShadow: isActive ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(Article article) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Buka Halaman Detail
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewsDetailScreen(article: article)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR COVER
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      article.urlToImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(color: Colors.grey.shade200),
                    ),
                    // Gradient Overlay bawah
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    // Badge Source
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                        child: Text(article.sourceName, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // JUDUL & DESKRIPSI
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(DateTime.tryParse(article.publishedAt) ?? DateTime.now()),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3),
                    ),
                    const Spacer(),
                    const Row(
                      children: [
                        Text("Baca Selengkapnya", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0F172A)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(int gridCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridCount, childAspectRatio: 0.8, crossAxisSpacing: 20, mainAxisSpacing: 20),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200, highlightColor: Colors.white,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}