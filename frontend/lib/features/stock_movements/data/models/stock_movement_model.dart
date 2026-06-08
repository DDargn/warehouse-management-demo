class StockMovementModel {
  const StockMovementModel({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantity,
    required this.reason,
    required this.createdAt,
  });

  final int id;
  final int productId;
  final String movementType;
  final int quantity;
  final String? reason;
  final DateTime createdAt;

  bool get isInput => movementType == 'IN';

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      movementType: json['movement_type'] as String,
      quantity: json['quantity'] as int,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
