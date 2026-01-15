import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final Article article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // APP BAR DENGAN GAMBAR BESAR (PARALLAX EFFECT)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.urlToImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(color: Colors.grey),
                  ),
                  // Dark Overlay agar tombol back terlihat
                  Container(color: Colors.black.withOpacity(0.3)),
                ],
              ),
            ),
          ),

          // KONTEN BERITA
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                        child: Text(article.sourceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.tryParse(article.publishedAt) ?? DateTime.now()),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Judul
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.3, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Isi Berita (Deskripsi)
                  Text(
                    article.description.isNotEmpty ? article.description : "Tidak ada deskripsi tersedia untuk berita ini.",
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF334155)),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Tombol Baca Sumber Asli
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Di masa depan bisa pakai url_launcher
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur buka browser belum ditambahkan (perlu url_launcher)")));
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text("Buka di Browser"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}