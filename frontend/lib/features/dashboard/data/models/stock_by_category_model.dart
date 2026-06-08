class StockByCategoryModel {
  const StockByCategoryModel({
    required this.category,
    required this.totalProducts,
    required this.totalStockUnits,
    required this.stockValue,
  });

  final String category;
  final int totalProducts;
  final int totalStockUnits;
  final double stockValue;

  factory StockByCategoryModel.fromJson(Map<String, dynamic> json) {
    return StockByCategoryModel(
      category: json['category'] as String,
      totalProducts: _toInt(json['total_products']),
      totalStockUnits: _toInt(json['total_stock_units']),
      stockValue: _toDouble(json['stock_value']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }
}
