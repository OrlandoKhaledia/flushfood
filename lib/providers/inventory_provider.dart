import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../data/models/inventory_item.dart';
import '../services/notification_service.dart';

class InventoryProvider with ChangeNotifier {
  static const _boxName = 'inventory_box';

  final NotificationService notificationService;

  InventoryProvider({required this.notificationService});

  bool isLoading = true;
  List<InventoryItem> items = [];

  Future<void> loadItems() async {
    isLoading = true;
    notifyListeners();

    final box = await Hive.openBox<InventoryItem>(_boxName);
    items = box.values.toList();

    // If empty, add sample data
    if (items.isEmpty) {
      await _addSampleData(box);
      items = box.values.toList();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _addSampleData(Box<InventoryItem> box) async {
    final now = DateTime.now();
    final sample = InventoryItem(
      id: const Uuid().v4(),
      name: 'Bananas',
      category: ItemCategory.fruits,
      quantity: 6,
      unit: 'pcs',
      purchaseDate: now.subtract(const Duration(days: 2)),
      expiryDate: now.add(const Duration(days: 4)),
      notes: 'Ripe and sweet',
    );
    await box.put(sample.id, sample);

    final sample2 = InventoryItem(
      id: const Uuid().v4(),
      name: 'Milk',
      category: ItemCategory.dairy,
      quantity: 1,
      unit: 'L',
      purchaseDate: now.subtract(const Duration(days: 1)),
      expiryDate: now.add(const Duration(days: 3)),
      notes: '2% fat',
    );
    await box.put(sample2.id, sample2);

    // Schedule notifications for these items
    await notificationService.scheduleExpiryNotificationsForItem(sample);
    await notificationService.scheduleExpiryNotificationsForItem(sample2);
    // Additional demo items
    final sample3 = InventoryItem(
      id: const Uuid().v4(),
      name: 'Carrots',
      category: ItemCategory.vegetables,
      quantity: 2,
      unit: 'pcs',
      purchaseDate: now.subtract(const Duration(days: 1)),
      expiryDate: now.add(const Duration(days: 10)),
      notes: 'Crunchy',
    );
    await box.put(sample3.id, sample3);

    final sample4 = InventoryItem(
      id: const Uuid().v4(),
      name: 'Orange Juice',
      category: ItemCategory.beverages,
      quantity: 1,
      unit: 'L',
      purchaseDate: now.subtract(const Duration(days: 3)),
      expiryDate: now.add(const Duration(days: 7)),
    );
    await box.put(sample4.id, sample4);

    await notificationService.scheduleExpiryNotificationsForItem(sample3);
    await notificationService.scheduleExpiryNotificationsForItem(sample4);
  }

  Future<void> addItem(InventoryItem item) async {
    final box = await Hive.openBox<InventoryItem>(_boxName);
    final id = item.id.isEmpty ? const Uuid().v4() : item.id;
    item.id = id;
    await box.put(id, item);
    items = box.values.toList();
    await notificationService.scheduleExpiryNotificationsForItem(item);
    notifyListeners();
  }

  Future<void> updateItem(InventoryItem item) async {
    final box = await Hive.openBox<InventoryItem>(_boxName);
    await box.put(item.id, item);
    items = box.values.toList();
    await notificationService.cancelNotificationsForItem(item.id);
    await notificationService.scheduleExpiryNotificationsForItem(item);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final box = await Hive.openBox<InventoryItem>(_boxName);
    await box.delete(id);
    items = box.values.toList();
    await notificationService.cancelNotificationsForItem(id);
    notifyListeners();
  }

  List<InventoryItem> expiringSoon({int days = 3}) {
    final cutoff = DateTime.now().add(Duration(days: days));
    return items.where((i) => i.expiryDate.isBefore(cutoff)).toList();
  }

  List<InventoryItem> lowStock({double threshold = 1.0}) {
    return items.where((i) => i.quantity <= threshold).toList();
  }

  // Returns a filtered view of items based on query and optional filters.
  List<InventoryItem> filteredItems({
    String? query,
    ItemCategory? category,
    int? expiringInDays,
    double? lowStockThreshold,
  }) {
    var result = items;

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((i) => i.name.toLowerCase().contains(q)).toList();
    }

    if (category != null) {
      result = result.where((i) => i.category == category).toList();
    }

    if (expiringInDays != null) {
      final cutoff = DateTime.now().add(Duration(days: expiringInDays));
      result = result.where((i) => i.expiryDate.isBefore(cutoff)).toList();
    }

    if (lowStockThreshold != null) {
      result = result.where((i) => i.quantity <= lowStockThreshold).toList();
    }

    return result;
  }
}
