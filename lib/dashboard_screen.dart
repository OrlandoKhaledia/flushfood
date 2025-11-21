import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flushfood/providers/inventory_provider.dart';
import 'package:flushfood/add_edit_item_screen.dart';
import 'package:flushfood/inventory_list_item.dart';
import 'package:flushfood/screens/settings_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:flushfood/widgets/tutorial_service.dart';
import 'package:flushfood/data/models/inventory_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  ItemCategory? _filterCategory;
  int? _expiringInDays;
  double? _lowStockThreshold;
  String _sortBy = 'expiry';

  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _firstItemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Load items when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      if (provider.items.isEmpty) {
        provider.loadItems();
      }
    });

    // Register tutorial keys so overlay can find them
    TutorialService.instance.registerKey('fab', _fabKey);
    TutorialService.instance.registerKey('settings', _settingsKey);
    TutorialService.instance.registerKey('firstItem', _firstItemKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).dashboardTitle),
        actions: [
          IconButton(
            key: _settingsKey,
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (v) => setState(() => _sortBy = v),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'expiry', child: Text(AppLocalizations.of(context).sortByExpiry)),
                    PopupMenuItem(value: 'name', child: Text(AppLocalizations.of(context).sortByName)),
                  ],
                  icon: const Icon(Icons.sort),
                )
              ],
            ),
          ),
        ),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = provider.filteredItems(
            query: _searchController.text,
            category: _filterCategory,
            expiringInDays: _expiringInDays,
            lowStockThreshold: _lowStockThreshold,
          );

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context).emptyState,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          // Optionally sort
          if (_sortBy == 'expiry') {
            filtered.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
          } else {
            filtered.sort((a, b) => a.name.compareTo(b.name));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSummary(provider),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ItemCategory.values
                    .map((c) => ChoiceChip(
                          label: Text(c.toString().split('.').last),
                          selected: _filterCategory == c,
                          onSelected: (sel) => setState(() => _filterCategory = sel ? c : null),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              ...filtered.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                return InventoryListItem(key: idx == 0 ? _firstItemKey : null, item: item);
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddEditItemScreen()));
        },
        tooltip: AppLocalizations.of(context).addItemTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary(InventoryProvider provider) {
    final total = provider.items.length;
    final expiring = provider.expiringSoon(days: 3).length;
    final low = provider.lowStock().length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard(AppLocalizations.of(context).total, total.toString(), Colors.blue),
        const SizedBox(width: 8),
        _statCard(AppLocalizations.of(context).expiring, expiring.toString(), Colors.orange),
        const SizedBox(width: 8),
        _statCard(AppLocalizations.of(context).low, low.toString(), Colors.red),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) => Expanded(
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
}