class Stock {
  String code;
  double HargaJual;
  double HargaBeli;
  double dividen;

  Stock({
    required this.code,
    required this.HargaBeli,
    required this.HargaJual,
    required this.dividen,
  });

  double get roi =>
      (((HargaJual - HargaBeli) + dividen) / HargaBeli) * 100;
}

class KpiData {
  String name;
  double target;

  KpiData({required this.name, required this.target});
}