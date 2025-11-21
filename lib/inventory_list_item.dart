import 'dart:io';

import 'package:flushfood/data/models/inventory_item.dart';
import 'package:flushfood/add_edit_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InventoryListItem extends StatelessWidget {
  final InventoryItem item;

  const InventoryListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = item.expiryDate.isBefore(now);
    final daysUntilExpiry = item.expiryDate.difference(now).inDays;

    Color expiryColor;
    if (isExpired) {
      expiryColor = Colors.red;
    } else if (daysUntilExpiry <= 3) {
      expiryColor = Colors.orange;
    } else {
      expiryColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade100,
          child: ClipOval(
            child: item.imagePath != null && item.imagePath!.isNotEmpty
                ? Image.file(File(item.imagePath!), width: 48, height: 48, fit: BoxFit.cover)
                : SvgPicture.asset('assets/images/placeholder_food.svg', width: 48, height: 48),
          ),
        ),
        title: Text(item.name),
        subtitle: Text(
            'Qty: ${item.quantity} ${item.unit} • Expires: ${DateFormat.yMd().format(item.expiryDate)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isExpired
                  ? 'Expired'
                  : '$daysUntilExpiry day${daysUntilExpiry == 1 ? '' : 's'}',
              style: TextStyle(color: expiryColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: () {
          // For now, navigate directly to edit. Later, this can go to a details screen.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditItemScreen(item: item),
            ),
          );
        },
      ),
    );
  }
}