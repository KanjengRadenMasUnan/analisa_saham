import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class NewsService {
  final String _apiKey = "c12601879a2f436686663beb18a683dc";
  final String _baseUrl = "https://newsapi.org/v2";

  // Fungsi fetch dengan parameter region
  Future<List<Article>> fetchNews(String region) async {
    String url = "";

    // LOGIKA PEMILIHAN URL BERDASARKAN WILAYAH
    switch (region) {
      case "ID": // Indonesia (Fokus Bisnis)
        url = "$_baseUrl/top-headlines?country=id&category=business&apiKey=$_apiKey";
        break;
      case "US": // Amerika (Fokus Bisnis & Politik)
        url = "$_baseUrl/top-headlines?country=us&category=business&apiKey=$_apiKey";
        break;
      case "CN": // China (Keyword Search karena country=cn sering kosong di API gratis)
        url = "$_baseUrl/everything?q=china economy OR china stock market&language=en&sortBy=publishedAt&apiKey=$_apiKey";
        break;
      case "EU": // Uni Eropa (Keyword Search)
        url = "$_baseUrl/everything?q=europe economy OR ecb OR euro market&language=en&sortBy=publishedAt&apiKey=$_apiKey";
        break;
      default:
        url = "$_baseUrl/top-headlines?country=id&category=business&apiKey=$_apiKey";
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'];
        
        return articlesJson
            .where((json) => json['title'] != "[Removed]" && json['urlToImage'] != null) // Filter berita rusak
            .map((json) => Article.fromJson(json))
            .toList();
      } else {
        throw Exception('Gagal memuat berita: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR BERITA: $e");
      return [];
    }
  }
}