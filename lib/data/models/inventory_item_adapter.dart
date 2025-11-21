import 'package:hive/hive.dart';
import 'inventory_item.dart';

class InventoryItemAdapter extends TypeAdapter<InventoryItem> {
  @override
  final int typeId = 1;

  @override
  InventoryItem read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: ItemCategory.values[map['category'] as int],
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      notes: map['notes'] as String?,
      imagePath: map['imagePath'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'category': obj.category.index,
      'quantity': obj.quantity,
      'unit': obj.unit,
      'purchaseDate': obj.purchaseDate.toIso8601String(),
      'expiryDate': obj.expiryDate.toIso8601String(),
      'notes': obj.notes,
      'imagePath': obj.imagePath,
    });
  }
}
