class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.description,
    required this.stock,
    required this.minStock,
    required this.location,
    required this.unitPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String sku;
  final String category;
  final String? description;
  final int stock;
  final int minStock;
  final String? location;
  final double unitPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stock < minStock;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      stock: json['stock'] as int,
      minStock: json['min_stock'] as int,
      location: json['location'] as String?,
      unitPrice: _toDouble(json['unit_price']),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }
}

class ProductPayload {
  const ProductPayload({
    required this.name,
    required this.sku,
    required this.category,
    required this.description,
    required this.stock,
    required this.minStock,
    required this.location,
    required this.unitPrice,
  });

  final String name;
  final String sku;
  final String category;
  final String? description;
  final int stock;
  final int minStock;
  final String? location;
  final double unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'description': description,
      'stock': stock,
      'min_stock': minStock,
      'location': location,
      'unit_price': unitPrice,
    };
  }
}
