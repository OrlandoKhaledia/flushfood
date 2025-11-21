// Lightweight InventoryItem model. A manual Hive TypeAdapter is provided
// in `inventory_item_adapter.dart` and registered at app start.

enum ItemCategory { fruits, vegetables, dairy, meat, pantry, beverages, other }

class InventoryItem {
  String id;
  String name;
  ItemCategory category;
  double quantity;
  String unit;
  DateTime purchaseDate;
  DateTime expiryDate;
  String? notes;
  String? imagePath;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    required this.expiryDate,
    this.notes,
    this.imagePath,
  });

  bool get isLowStock => quantity <= 1.0;

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  @override
  String toString() => 'InventoryItem($name)';
}

