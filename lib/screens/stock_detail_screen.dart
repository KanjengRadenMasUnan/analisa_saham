import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/market_service.dart';

class StockDetailScreen extends StatefulWidget {
  final String ticker;
  final Map<String, dynamic> currentData;

  const StockDetailScreen({super.key, required this.ticker, required this.currentData});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final MarketService _service = MarketService();
  late Future<List<double>> _chartFuture;

  @override
  void initState() {
    super.initState();
    _chartFuture = _service.getChartData(widget.ticker);
  }

  @override
  Widget build(BuildContext context) {
    final isUp = widget.currentData['isUp'];
    final color = isUp ? Colors.green : Colors.red;
    final price = widget.currentData['price'];

    return Scaffold(
      appBar: AppBar(title: Text(widget.ticker)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.ticker == "IHSG" ? "IHSG Composite" : "${widget.ticker} Tbk", 
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text("Rp ${NumberFormat('#,###').format(price)}", 
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const Text("Pergerakan Harga (Hourly)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: FutureBuilder<List<double>>(
                future: _chartFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text("Gagal memuat grafik"));

                  final dataPoints = snapshot.data!;
                  double minY = dataPoints.reduce((curr, next) => curr < next ? curr : next);
                  double maxY = dataPoints.reduce((curr, next) => curr > next ? curr : next);

                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minY: minY * 0.99,
                      maxY: maxY * 1.01,
                      // ... di dalam LineChartData ...
                    lineBarsData: [
                      LineChartBarData(
                        spots: dataPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: color,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          // WARNA GRADASI DI BAWAH GRAFIK
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.3),
                              color.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                   ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}