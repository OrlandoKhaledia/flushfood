import 'dart:io';

import 'package:flushfood/data/models/inventory_item.dart';
import 'package:flushfood/providers/inventory_provider.dart';
import 'package:flushfood/add_edit_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemDetailsScreen extends StatelessWidget {
  final InventoryItem item;

  const ItemDetailsScreen({super.key, required this.item});

  // Helper to show a confirmation dialog before deleting
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to permanently delete this item?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Yes'),
            onPressed: () {
              // Pop the dialog
              Navigator.of(ctx).pop();
              // Delete the item and pop the details screen
              Provider.of<InventoryProvider>(context, listen: false)
                  .deleteItem(item.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Item',
            onPressed: () {
              // Navigate to the edit screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AddEditItemScreen(item: item),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Item',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: 220,
              child: item.imagePath != null && item.imagePath!.isNotEmpty
                  ? Image.file(File(item.imagePath!), fit: BoxFit.cover)
                  : Center(child: SvgPicture.asset('assets/images/placeholder_food.svg', width: 140)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Category', item.category.toString().split('.').last, textTheme),
                  _buildDetailRow('Quantity', '${item.quantity} ${item.unit}', textTheme),
                  _buildDetailRow('Purchase Date', DateFormat.yMMMd().format(item.purchaseDate), textTheme),
                  _buildDetailRow('Expiry Date', DateFormat.yMMMd().format(item.expiryDate), textTheme),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    _buildDetailRow('Notes', item.notes!, textTheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
