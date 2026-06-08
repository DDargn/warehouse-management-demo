class AnalyticsSummaryModel {
  const AnalyticsSummaryModel({
    required this.totalProducts,
    required this.totalStockUnits,
    required this.lowStockProducts,
    required this.totalMovements,
    required this.stockValue,
    required this.categoriesCount,
    required this.averageStockPerProduct,
  });

  final int totalProducts;
  final int totalStockUnits;
  final int lowStockProducts;
  final int totalMovements;
  final double stockValue;
  final int categoriesCount;
  final double averageStockPerProduct;

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      totalProducts: _toInt(json['total_products']),
      totalStockUnits: _toInt(json['total_stock_units']),
      lowStockProducts: _toInt(json['low_stock_products']),
      totalMovements: _toInt(json['total_movements']),
      stockValue: _toDouble(json['stock_value']),
      categoriesCount: _toInt(json['categories_count']),
      averageStockPerProduct: _toDouble(json['average_stock_per_product']),
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
