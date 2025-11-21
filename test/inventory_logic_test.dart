import 'package:flutter_test/flutter_test.dart';
import 'package:flushfood/data/models/inventory_item.dart';
import 'package:flushfood/providers/inventory_provider.dart';
import 'package:flushfood/services/notification_service.dart';

class FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleExpiryNotificationsForItem(InventoryItem item) async {}

  @override
  Future<void> cancelNotificationsForItem(String id) async {}
}

void main() {
  test('expiringSoon and lowStock helpers', () async {
    final provider = InventoryProvider(notificationService: FakeNotificationService());

    final now = DateTime.now();
    final item1 = InventoryItem(
      id: '1',
      name: 'Yogurt',
      category: ItemCategory.dairy,
      quantity: 0.5,
      unit: 'L',
      purchaseDate: now.subtract(const Duration(days: 2)),
      expiryDate: now.add(const Duration(days: 2)),
    );

    final item2 = InventoryItem(
      id: '2',
      name: 'Apple',
      category: ItemCategory.fruits,
      quantity: 5,
      unit: 'pcs',
      purchaseDate: now.subtract(const Duration(days: 1)),
      expiryDate: now.add(const Duration(days: 10)),
    );

    provider.items = [item1, item2];

    final expiring = provider.expiringSoon(days: 3);
    expect(expiring.length, 1);
    expect(expiring.first.name, 'Yogurt');

    final low = provider.lowStock(threshold: 1.0);
    expect(low.length, 1);
    expect(low.first.name, 'Yogurt');
  });
}
