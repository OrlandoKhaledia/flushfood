import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(builder: (context, provider, _) {
      final expiring = provider.expiringSoon(days: 7);
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: expiring.isEmpty
            ? const Center(child: Text('No upcoming expiries'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: expiring.length,
                itemBuilder: (ctx, i) {
                  final it = expiring[i];
                  final days = it.expiryDate.difference(DateTime.now()).inDays;
                  return Card(
                    child: ListTile(
                      title: Text(it.name),
                      subtitle: Text('Expires in $days day${days == 1 ? '' : 's'}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'snooze') {
                            // snooze: push expiry +1 day
                            it.expiryDate = it.expiryDate.add(const Duration(days: 1));
                            await provider.updateItem(it);
                          } else if (v == 'used') {
                            // mark as used: decrement or remove
                            if (it.quantity > 1) {
                              it.quantity = it.quantity - 1;
                              await provider.updateItem(it);
                            } else {
                              await provider.deleteItem(it.id);
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'snooze', child: Text('Snooze 1 day')),
                          PopupMenuItem(value: 'used', child: Text('Mark as used')),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}
