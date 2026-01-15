import '../models/stock_model.dart';

class PortfolioLogic {
  double calculateAverageRoi(List<Stock> portfolio) {
    if (portfolio.isEmpty) return 0.0;
    double totalRoi = 0;
    for (var stock in portfolio) {
      totalRoi += stock.roi;
    }
    return totalRoi / portfolio.length;
  }

  List<String> evaluateKpi(double avgRoi, List<KpiData> kpiList) {
    List<String> results = [];
    if (kpiList.isEmpty) {
      results.add("⚠️ Tidak ada KPI yang dimasukkan.");
      return results;
    }
    for (var kpi in kpiList) {
      bool isPassed = avgRoi > kpi.target;
      String status = isPassed ? "✅ LULUS" : "❌ GAGAL";
      results.add("$status ${kpi.name} (Target > ${kpi.target}%)");
    }
    return results;
  }

  Map<String, dynamic> getConclusion(double avgRoi, List<KpiData> kpiList) {
    if (kpiList.isEmpty) return {"text": "Data Tidak Lengkap", "score": 0};
    
    int passedCount = 0;
    for (var kpi in kpiList) {
      if (avgRoi > kpi.target) passedCount++;
    }

<<<<<<< HEAD
    if (passedCount == kpiList.length) {
      return {"text": "KINERJA SEMPURNA", "score": 3};
    } else if (passedCount > (kpiList.length / 2)) return {"text": "KINERJA BAIK", "score": 2};
=======
    if (passedCount == kpiList.length) return {"text": "KINERJA SEMPURNA", "score": 3};
    else if (passedCount > (kpiList.length / 2)) return {"text": "KINERJA BAIK", "score": 2};
>>>>>>> 7fc534e96433993aa512f8e598f408c960b8efd9
    else if (passedCount > 0) return {"text": "KINERJA MODERAT", "score": 1};
    else return {"text": "KINERJA BURUK", "score": 0};
  }
}