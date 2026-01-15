import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class MarketService {
<<<<<<< HEAD
  // Simpan data di memori agar tidak download terus-menerus
  static final Map<String, dynamic> _priceCache = {};
  static final Map<String, DateTime> _cacheTime = {};

  Future<Map<String, dynamic>> getStockPrice(String ticker) async {
    // 1. CEK CACHE: Jika data kurang dari 5 menit, pakai data lama
    if (_priceCache.containsKey(ticker)) {
      final difference = DateTime.now().difference(_cacheTime[ticker]!);
      if (difference.inMinutes < 5) {
        return _priceCache[ticker];
      }
    }

    try {
      // 2. KASIH JEDA: Biar server tidak kaget (Anti-429)
      // Kita beri random delay 100-500ms
      await Future.delayed(Duration(milliseconds: Random().nextInt(400) + 100));

      String formattedTicker = ticker == "IHSG" ? "^JKSE" : "$ticker.JK";
      
      // Gunakan Proxy yang berbeda jika satu error
      String url = 'https://query1.finance.yahoo.com/v8/finance/chart/$formattedTicker?interval=1d&range=1d';
      
      final response = await http.get(Uri.parse(url), headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0"
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meta = data['chart']['result'][0]['meta'];
        
        final result = {
          'symbol': ticker,
          'price': (meta['regularMarketPrice'] as num).toDouble(),
          'change': (meta['regularMarketPrice'] as num).toDouble() - (meta['chartPreviousClose'] as num).toDouble(),
          'changePercent': ((meta['regularMarketPrice'] as num).toDouble() - (meta['chartPreviousClose'] as num).toDouble()) / (meta['chartPreviousClose'] as num).toDouble() * 100,
          'isUp': (meta['regularMarketPrice'] as num).toDouble() >= (meta['chartPreviousClose'] as num).toDouble(),
        };

        // Simpan ke Cache
        _priceCache[ticker] = result;
        _cacheTime[ticker] = DateTime.now();

        return result;
      } else if (response.statusCode == 429) {
        print("!! Rate Limit Hit (429) for $ticker. Menggunakan data simulasi.");
        return _getDummyData(ticker);
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("! Yahoo Error ($ticker): $e. Menggunakan Data Simulasi.");
=======
  
  // --- FUNGSI 1: AMBIL HARGA SAHAM (QUOTE) ---
  Future<Map<String, dynamic>> getStockPrice(String ticker) async {
    try {
      return await _fetchFromYahooWithProxy(ticker);
    } catch (e) {
      print("⚠️ Yahoo Error ($ticker): $e. Menggunakan Data Simulasi.");
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
      return _getDummyData(ticker);
    }
  }

<<<<<<< HEAD
  // --- Fungsi Chart juga perlu jeda ---
  Future<List<double>> getChartData(String ticker) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Jeda lebih lama untuk grafik
      // ... (sisa kode fetch chart Mas yang sebelumnya) ...
      return _getDummyChartData(); // Placeholder
    } catch (e) {
=======
  // --- FUNGSI 2: AMBIL GRAFIK SAHAM (CHART) ---
  Future<List<double>> getChartData(String ticker) async {
    try {
      return await _fetchChartFromYahooWithProxy(ticker);
    } catch (e) {
      print("⚠️ Yahoo Chart Error ($ticker): $e. Menggunakan Grafik Simulasi.");
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
      return _getDummyChartData();
    }
  }

<<<<<<< HEAD
  Map<String, dynamic> _getDummyData(String ticker) {
    // Tetap kembalikan data simulasi agar UI tidak kosong/merah
    return {
      'symbol': ticker,
      'price': 5000.0,
      'change': 0.0,
      'changePercent': 0.0,
      'isUp': true,
=======
  // --- LOGIKA UTAMA: YAHOO LEWAT PROXY (AGAR TEMBUS WEB/CORS) ---

  Future<Map<String, dynamic>> _fetchFromYahooWithProxy(String ticker) async {
    // 1. Format Ticker
    String formattedTicker = ticker;
    if (ticker == "IHSG") formattedTicker = "^JKSE";
    else if (!ticker.contains(".")) formattedTicker = "$ticker.JK";

    // 2. URL Asli Yahoo
    String yahooUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/$formattedTicker?interval=1d&range=1d';

    // 3. GUNAKAN PROXY "ALLORIGINS" AGAR TIDAK DIBLOKIR BROWSER
    // Konsep: App -> Proxy -> Yahoo -> Proxy -> App
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
      double changePercent = (change / previousClose) * 100;

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
    if (ticker == "IHSG") formattedTicker = "^JKSE";
    else if (!ticker.contains(".")) formattedTicker = "$ticker.JK";

    // URL Chart Yahoo
    String yahooUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/$formattedTicker?interval=60m&range=5d';
    
    // Bungkus dengan Proxy
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
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
    };
  }

  List<double> _getDummyChartData() {
<<<<<<< HEAD
    return List.generate(20, (index) => 5000.0 + Random().nextInt(100));
=======
    return List.generate(50, (index) => 5000.0 + Random().nextInt(500));
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
  }
}