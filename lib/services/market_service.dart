import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class MarketService {
  // Simpan data di memori agar tidak download terus-menerus
  static final Map<String, dynamic> _priceCache = {};
  static final Map<String, DateTime> _cacheTime = {};

  // --- FUNGSI 1: AMBIL HARGA SAHAM (QUOTE) ---
  Future<Map<String, dynamic>> getStockPrice(String ticker) async {
    // 1. CEK CACHE: Jika data kurang dari 5 menit, pakai data lama
    if (_priceCache.containsKey(ticker)) {
      final difference = DateTime.now().difference(_cacheTime[ticker]!);
      if (difference.inMinutes < 5) {
        return _priceCache[ticker];
      }
    }

    try {
      final result = await _fetchFromYahooWithProxy(ticker);
      
      // Simpan ke Cache jika berhasil
      _priceCache[ticker] = result;
      _cacheTime[ticker] = DateTime.now();
      
      return result;
    } catch (e) {
      print("⚠️ Yahoo Error ($ticker): $e. Menggunakan Data Simulasi.");
      return _getDummyData(ticker);
    }
  }

  // --- FUNGSI 2: AMBIL GRAFIK SAHAM (CHART) ---
  Future<List<double>> getChartData(String ticker) async {
    try {
      // Kita beri sedikit jeda agar server tidak menolak permintaan beruntun
      await Future.delayed(const Duration(milliseconds: 500)); 
      return await _fetchChartFromYahooWithProxy(ticker);
    } catch (e) {
      print("⚠️ Yahoo Chart Error ($ticker): $e. Menggunakan Grafik Simulasi.");
      return _getDummyChartData();
    }
  }

  // --- LOGIKA UTAMA: YAHOO LEWAT PROXY (AGAR TEMBUS WEB/CORS) ---

  Future<Map<String, dynamic>> _fetchFromYahooWithProxy(String ticker) async {
    String formattedTicker = ticker;
    if (ticker == "IHSG") {
      formattedTicker = "^JKSE";
    } else if (!ticker.contains(".")) {
      formattedTicker = "$ticker.JK";
    }

    String yahooUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/$formattedTicker?interval=1d&range=1d';
    String proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(yahooUrl)}";

    final response = await http.get(Uri.parse(proxyUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['chart']['result'] == null || data['chart']['result'].isEmpty) {
        throw Exception("Data Yahoo Kosong");
      }

      final result = data['chart']['result'][0];
      final meta = result['meta'];
      
      double currentPrice = (meta['regularMarketPrice'] as num).toDouble();
      double previousClose = (meta['chartPreviousClose'] as num).toDouble();
      double change = currentPrice - previousClose;
      double changePercent = (previousClose != 0) ? (change / previousClose) * 100 : 0.0;

      return {
        'symbol': ticker,
        'price': currentPrice,
        'change': change,
        'changePercent': changePercent,
        'isUp': change >= 0,
      };
    } else {
      throw Exception("HTTP Error: ${response.statusCode}");
    }
  }

  Future<List<double>> _fetchChartFromYahooWithProxy(String ticker) async {
    String formattedTicker = ticker;
    if (ticker == "IHSG") {
      formattedTicker = "^JKSE";
    } else if (!ticker.contains(".")) {
      formattedTicker = "$ticker.JK";
    }

    String yahooUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/$formattedTicker?interval=60m&range=5d';
    String proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(yahooUrl)}";

    final response = await http.get(Uri.parse(proxyUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['chart']['result'][0];
      final List<dynamic> quote = result['indicators']['quote'][0]['close'];
      
      List<double> cleanData = quote
          .where((e) => e != null)
          .map((e) => (e as num).toDouble())
          .toList();

      if (cleanData.length > 50) {
        cleanData = cleanData.sublist(cleanData.length - 50);
      }
      
      return cleanData;
    } else {
      throw Exception("Chart Gagal Load");
    }
  }

  // --- DATA CADANGAN (JIKA PROXY PUN GAGAL) ---
  Map<String, dynamic> _getDummyData(String ticker) {
    double price = 1000.0;
    double change = 10.0;
    
    switch (ticker) {
      case "IHSG": price = 7321.0; change = 32.0; break;
      case "BBCA": price = 9850.0; change = 125.0; break;
      case "BBRI": price = 5450.0; change = -50.0; break;
      case "BMRI": price = 7200.0; change = 75.0; break;
      case "TLKM": price = 3180.0; change = -20.0; break;
      case "GOTO": price = 68.0; change = -2.0; break;
      case "ASII": price = 5150.0; change = 0.0; break;
      case "ANTM": price = 1540.0; change = 15.0; break;
    }
    
    final random = Random();
    price += (random.nextDouble() * 20) - 10;

    return {
      'symbol': ticker,
      'price': price, 
      'change': change,
      'changePercent': (change / price) * 100,
      'isUp': change >= 0,
    };
  }

  List<double> _getDummyChartData() {
    return List.generate(50, (index) => 5000.0 + Random().nextInt(500));
  }
}