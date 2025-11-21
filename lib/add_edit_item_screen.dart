import 'dart:io';

import 'package:flushfood/data/models/inventory_item.dart';
import 'package:flushfood/providers/inventory_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddEditItemScreen extends StatefulWidget {
  final InventoryItem? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;

  // Form fields
  late String _name;
  late ItemCategory _category;
  late double _quantity;
  late String _unit;
  late DateTime _purchaseDate;
  late DateTime _expiryDate;
  String? _notes;

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.item != null;

    if (_isEditing) {
      // Pre-fill form for editing
      final item = widget.item!;
      _name = item.name;
      _category = item.category;
      _quantity = item.quantity;
      _unit = item.unit;
      _purchaseDate = item.purchaseDate;
      _expiryDate = item.expiryDate;
      _notes = item.notes;

      _nameController.text = _name;
      _quantityController.text = _quantity.toString();
      _unitController.text = _unit;
      _notesController.text = _notes ?? '';
      _imagePath = item.imagePath;
    } else {
      // Set defaults for new item
      _name = '';
      _category = ItemCategory.other;
      _quantity = 1.0;
      _unit = 'pcs';
      _purchaseDate = DateTime.now();
      _expiryDate = DateTime.now().add(const Duration(days: 7));
      _notes = '';

      _quantityController.text = _quantity.toString();
      _unitController.text = _unit;
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isPurchaseDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPurchaseDate ? _purchaseDate : _expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final inventoryProvider =
          Provider.of<InventoryProvider>(context, listen: false);

      final newItem = InventoryItem(
        id: _isEditing ? widget.item!.id : '', // ID is set in provider for new
        name: _name,
        category: _category,
        quantity: _quantity,
        unit: _unit,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        notes: _notes,
        imagePath: _imagePath,
      );

      if (_isEditing) {
        inventoryProvider.updateItem(newItem);
      } else {
        inventoryProvider.addItem(newItem);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
            tooltip: 'Save Item',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Choose from gallery'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take a photo'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickImage(ImageSource.camera);
                            },
                          ),
                            if (_imagePath != null)
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Remove photo'),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Remove photo'),
                                      content: const Text('Are you sure you want to remove the photo?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    setState(() {
                                      _imagePath = null;
                                    });
                                  }
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                  child: _imagePath == null
                      ? SizedBox(
                          height: 140,
                          child: Center(child: SvgPicture.asset('assets/images/placeholder_food.svg', width: 96)),
                        )
                      : SizedBox(
                          height: 140,
                          child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                        ),
                ),
                const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
              onSaved: (value) => _name = value!,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ItemCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ItemCategory.values
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        double.tryParse(value!) == null ? 'Invalid number' : null,
                    onSaved: (value) => _quantity = double.parse(value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    onSaved: (value) => _unit = value!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Purchase Date'),
              subtitle: Text(DateFormat.yMd().format(_purchaseDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, isPurchaseDate: true),
            ),
            ListTile(
              title: const Text('Expiry Date'),
              subtitle: Text(DateFormat.yMd().format(_expiryDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, isPurchaseDate: false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              maxLines: 3,
              onSaved: (value) => _notes = value,
            ),
            // Image picker handled above; image path saved in `_imagePath`.
          ],
        ),
      ),
    );
  }
}