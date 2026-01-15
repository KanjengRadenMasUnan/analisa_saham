import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/stock_model.dart';
import '../services/portfolio_service.dart';
import '../utils/currency_formatter.dart';

class KpiUiItem {
  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();
}

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioLogic _logic = PortfolioLogic();
  
  // Controllers
  final _codeController = TextEditingController();
  final _beliController = TextEditingController();
  final _jualController = TextEditingController();
  final _divController = TextEditingController();
  
  // State KPI
  List<KpiUiItem> kpiUiList = [];
  
  // State Data
  List<Stock> portfolio = [];
  double? portfolioRoi;
  String conclusion = "";
  Color conclusionColor = Colors.grey;
  List<String> detailEvaluation = [];
  bool _isCalculating = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _addKpiField(); // Default 1 KPI kosong
  }

  @override
  void dispose() {
    _codeController.dispose(); _beliController.dispose();
    _jualController.dispose(); _divController.dispose();
    for (var item in kpiUiList) { item.nameController.dispose(); item.valueController.dispose(); }
    super.dispose();
  }

  double _parseCurrency(String text) => double.tryParse(text.replaceAll('.', '').replaceAll(',', '')) ?? 0;

  void _addStock() {
    if (_codeController.text.isEmpty || _beliController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kode & Harga Beli wajib diisi")));
      return;
    }
    setState(() {
      portfolio.insert(0, Stock(
        code: _codeController.text.toUpperCase(),
        HargaBeli: _parseCurrency(_beliController.text),
        HargaJual: _jualController.text.isEmpty ? _parseCurrency(_beliController.text) : _parseCurrency(_jualController.text),
        dividen: _parseCurrency(_divController.text),
      ));
      _codeController.clear(); _beliController.clear(); _jualController.clear(); _divController.clear();
    });
    if (MediaQuery.of(context).size.width <= 800) Navigator.pop(context);
  }

  void _addKpiField() => setState(() => kpiUiList.add(KpiUiItem()));
  void _removeKpiField(int index) => setState(() => kpiUiList.removeAt(index));

  Future<void> _processCalculation() async {
    if (portfolio.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masukkan minimal 1 saham untuk analisis")));
       return;
    }
    setState(() { _isCalculating = true; _showResults = false; });
    
    // Simulasi loading biar keren
    await Future.delayed(const Duration(milliseconds: 1000));

    // Ambil Data KPI
    List<KpiData> cleanKpiList = [];
    for (var item in kpiUiList) {
      if (item.valueController.text.isNotEmpty) {
        cleanKpiList.add(KpiData(
          name: item.nameController.text.isEmpty ? "Target Profit" : item.nameController.text,
          target: double.tryParse(item.valueController.text) ?? 0,
        ));
      }
    }

    // Default KPI jika kosong
    if (cleanKpiList.isEmpty) {
      cleanKpiList.add(KpiData(name: "Break Even Point", target: 0));
    }

    double avgRoi = _logic.calculateAverageRoi(portfolio);
    List<String> details = _logic.evaluateKpi(avgRoi, cleanKpiList);
    Map<String, dynamic> result = _logic.getConclusion(avgRoi, cleanKpiList);

    setState(() {
      portfolioRoi = avgRoi; detailEvaluation = details;
      conclusion = result['text']; _isCalculating = false; _showResults = true;
      conclusionColor = result['score'] >= 2 ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
      if (result['score'] == 0) conclusionColor = const Color(0xFFEF4444);
    });
  }

  double get _totalAssets {
    if (portfolio.isEmpty) return 0;
    return portfolio.fold(0, (sum, item) => sum + item.HargaBeli);
  }

  double get _totalGainLoss {
    if (portfolio.isEmpty) return 0;
    return portfolio.fold(0, (sum, item) => sum + (item.HargaJual - item.HargaBeli + item.dividen));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Portfolio Analysis"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      floatingActionButton: isDesktop ? null : FloatingActionButton.extended(
        onPressed: _showAddTransactionBottomSheet,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Transaksi"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. SUMMARY CARDS (Top)
            _buildSummaryCards(),
            const SizedBox(height: 24),

            // 2. MAIN LAYOUT
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildPortfolioList()),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1, 
                    child: Column(
                      children: [
                        _buildInputForm(), 
                        const SizedBox(height: 20), 
                        _buildPieChart(), 
                        const SizedBox(height: 20), 
                        _buildKpiSection() // KPI di Kanan Bawah untuk Desktop
                      ]
                    )
                  ),
                ],
              )
            else
              Column(
                children: [
                  if (portfolio.isNotEmpty) ...[
                    _buildPieChart(),
                    const SizedBox(height: 20),
                  ],
                  _buildPortfolioList(),
                  const SizedBox(height: 20),
                  _buildKpiSection(), // KPI di Bawah untuk Mobile
                  const SizedBox(height: 80),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text("Transaksi Baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            _buildTextField(_codeController, "Kode Emiten", icon: Icons.business),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _buildTextField(_beliController, "Beli", isNumber: true, prefix: "Rp ")), const SizedBox(width: 12), Expanded(child: _buildTextField(_jualController, "Jual/Market", isNumber: true, prefix: "Rp "))]),
            const SizedBox(height: 12),
            _buildTextField(_divController, "Dividen", isNumber: true, prefix: "Rp "),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _addStock, child: const Text("SIMPAN"))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSummaryCards() {
    return SizedBox(
      height: 140,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                 Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.wallet, color: Colors.white, size: 20)),
                 const Spacer(),
                 const Text("Total Equity", style: TextStyle(color: Colors.white70, fontSize: 12)),
                 Text("Rp ${NumberFormat.compact(locale: 'id').format(_totalAssets)}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                 Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (_totalGainLoss >= 0 ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.show_chart, color: _totalGainLoss >= 0 ? Colors.green : Colors.red, size: 20)),
                 const Spacer(),
                 const Text("Total Return", style: TextStyle(color: Colors.black54, fontSize: 12)),
                 Text("Rp ${NumberFormat.compact(locale: 'id').format(_totalGainLoss)}", style: TextStyle(color: _totalGainLoss >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 24, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioList() {
    return Column(
      children: [
        if (_showResults) _buildAnalysisResult()
            .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        if (_showResults) const SizedBox(height: 20),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
          child: Column(children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Holdings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(Icons.list_alt, color: Colors.grey)
            ]),
            const Divider(height: 30),
            if (portfolio.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text("Belum ada aset.")))
            else ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: portfolio.length, separatorBuilder: (_,__) => const Divider(height: 1), itemBuilder: (ctx, i) => _buildStockRow(portfolio[i])),
          ]),
        ),
      ],
    );
  }

  Widget _buildStockRow(Stock s) {
    bool isProfit = s.roi >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(s.code[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 18)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.code, style: const TextStyle(fontWeight: FontWeight.bold)), Text("Avg: ${NumberFormat.compact().format(s.HargaBeli)}", style: TextStyle(fontSize: 12, color: Colors.grey.shade500))])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("${isProfit ? '+' : ''}${s.roi.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, color: isProfit ? const Color(0xFF10B981) : const Color(0xFFEF4444))), Text("Rp ${NumberFormat.compact().format(s.HargaJual)}", style: const TextStyle(fontSize: 12))]),
      ]),
    );
  }

  // --- KPI / GOALS SECTION (BARU & MODERN) ---
  Widget _buildKpiSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        // Style yang sama dengan card lain
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.flag_rounded, color: Color(0xFF0F172A)),
                  SizedBox(width: 8),
                  Text("Target Goals (KPI)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              IconButton(
                onPressed: _addKpiField,
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0F172A)),
                tooltip: "Tambah Target",
              )
            ],
          ),
          const Divider(height: 20),
          
          if (kpiUiList.isEmpty)
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 10),
               child: Text("Belum ada target. Klik (+) untuk tambah.", style: TextStyle(color: Colors.grey, fontSize: 12)),
             ),

          // LIST INPUT KPI
          ...kpiUiList.asMap().entries.map((entry) {
            int i = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Nama KPI
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: kpiUiList[i].nameController,
                        decoration: const InputDecoration(
                          hintText: "Goal (cth: Min Profit)",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Target %
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: kpiUiList[i].valueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Target %",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  // Hapus Button
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                    onPressed: () => _removeKpiField(i),
                  )
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          
          // TOMBOL ANALISIS
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _processCalculation,
              icon: _isCalculating 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.analytics_outlined),
              label: Text(_isCalculating ? "MENGANALISIS..." : "ANALISIS PERFORMA"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF0F172A), width: 2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Input Transaksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        _buildTextField(_codeController, "Kode Emiten", icon: Icons.business),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: _buildTextField(_beliController, "Beli", isNumber: true)), const SizedBox(width: 12), Expanded(child: _buildTextField(_jualController, "Jual", isNumber: true))]),
        const SizedBox(height: 12),
        _buildTextField(_divController, "Dividen", isNumber: true),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _addStock, child: const Text("TAMBAH"))),
      ]),
    );
  }

  Widget _buildPieChart() {
    if (portfolio.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        const Text("Alokasi Aset", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(height: 180, child: PieChart(PieChartData(sectionsSpace: 0, centerSpaceRadius: 30, sections: portfolio.asMap().entries.map((entry) {
          final colors = [const Color(0xFF0F172A), const Color(0xFF334155), const Color(0xFF64748B), const Color(0xFF94A3B8), const Color(0xFFCBD5E1)];
          return PieChartSectionData(color: colors[entry.key % colors.length], value: entry.value.HargaBeli, title: entry.value.code, radius: 45, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold));
        }).toList()))),
      ]),
    );
  }

  Widget _buildAnalysisResult() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(children: [
        const Text("PERFORMA PORTOFOLIO", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("${portfolioRoi?.toStringAsFixed(2) ?? 0}%", style: TextStyle(color: conclusionColor, fontSize: 36, fontWeight: FontWeight.w900)),
        Text(conclusion, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        const Divider(color: Colors.white12),
        const SizedBox(height: 10),
        Column(children: detailEvaluation.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(e.contains("LULUS") ? Icons.check_circle : Icons.cancel, color: e.contains("LULUS") ? Colors.green : Colors.red, size: 16), const SizedBox(width: 12), Expanded(child: Text(e, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 12))) ]))).toList())
      ]),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumber = false, IconData? icon, String? prefix}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()] : [],
      decoration: InputDecoration(
        labelText: label, prefixText: prefix, prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
        filled: true, fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}