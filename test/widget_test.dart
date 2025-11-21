import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flushfood/providers/inventory_provider.dart';
import 'package:flushfood/dashboard_screen.dart';
import 'package:flushfood/services/notification_service.dart';
import 'package:flushfood/data/models/inventory_item.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flushfood/l10n/app_localizations.dart';

class FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleExpiryNotificationsForItem(item) async {}

  @override
  Future<void> cancelNotificationsForItem(String id) async {}
}

void main() {
  testWidgets('Dashboard shows items and FAB', (WidgetTester tester) async {
    final provider = InventoryProvider(notificationService: FakeNotificationService());
    provider.isLoading = false;
    provider.items = [
      // small sample
      
    ];

    provider.items = [
      InventoryItem(
        id: 't1',
        name: 'Test Item',
        category: ItemCategory.other,
        quantity: 2,
        unit: 'pcs',
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 5)),
      )
    ];

    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}
