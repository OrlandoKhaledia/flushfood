import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(builder: (context, provider, _) {
      final items = provider.lowStock();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Shopping List'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final content = items
                    .map((i) => '${i.name} - ${i.quantity} ${i.unit}')
                    .join('\n');

                // ✅ Correct call for share_plus v12
                Share.share(
                  content,
                  subject: 'My shopping list', // optional
                );
              },
            )
          ],
        ),
        body: items.isEmpty
            ? const Center(child: Text('No items to buy — all stocked!'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (ctx, idx) {
                  final it = items[idx];
                  return Card(
                    child: ListTile(
                      title: Text(it.name),
                      subtitle: Text('${it.quantity} ${it.unit}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () async {
                          // mark as bought: set quantity to a default (e.g., 1)
                          it.quantity = 1.0;
                          await provider.updateItem(it);
                        },
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}
