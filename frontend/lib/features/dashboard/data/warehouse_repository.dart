import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../products/data/models/product_model.dart';
import '../../stock_movements/data/models/stock_movement_model.dart';

class DashboardData {
  const DashboardData({
    required this.products,
    required this.lowStockProducts,
    required this.movements,
  });

  final List<ProductModel> products;
  final List<ProductModel> lowStockProducts;
  final List<StockMovementModel> movements;

  int get totalProducts => products.length;
  int get totalLowStockProducts => lowStockProducts.length;
  int get totalMovements => movements.length;
}

class WarehouseRepository {
  WarehouseRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<DashboardData> getDashboardData() async {
    final products = await getProducts();
    final lowStockProducts = await getProducts(lowStockOnly: true);
    final movements = await getStockMovements();

    return DashboardData(
      products: products,
      lowStockProducts: lowStockProducts,
      movements: movements,
    );
  }

  Future<List<ProductModel>> getProducts({
    bool lowStockOnly = false,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/products').replace(
      queryParameters: lowStockOnly
          ? {
              'low_stock_only': 'true',
            }
          : null,
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Error loading products. Status code: ${response.statusCode}',
      );
    }

    final List<dynamic> rawProducts = jsonDecode(response.body) as List<dynamic>;

    return rawProducts
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> createProduct(ProductPayload payload) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/products');

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Error creating product. Status code: ${response.statusCode}. Body: ${response.body}',
      );
    }

    return ProductModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct({
    required int productId,
    required ProductPayload payload,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/products/$productId');

    final response = await _client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error updating product. Status code: ${response.statusCode}. Body: ${response.body}',
      );
    }

    return ProductModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int productId) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/products/$productId');

    final response = await _client.delete(uri);

    if (response.statusCode != 204) {
      throw Exception(
        'Error deleting product. Status code: ${response.statusCode}. Body: ${response.body}',
      );
    }
  }

  Future<List<StockMovementModel>> getStockMovements() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/stock-movements');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Error loading stock movements. Status code: ${response.statusCode}',
      );
    }

    final List<dynamic> rawMovements = jsonDecode(response.body) as List<dynamic>;

    return rawMovements
        .map((item) => StockMovementModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
