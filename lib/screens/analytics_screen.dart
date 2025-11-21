import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lightweight placeholder for analytics to avoid charting package issues.
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Saved food items (last 7 days)'),
                subtitle: const Text('Visual charts disabled in this build.'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.redAccent),
                title: const Text('Wasted items (last 7 days)'),
                subtitle: const Text('Charts temporarily unavailable.'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'If you want charts, add a compatible `fl_chart` version in `pubspec.yaml` and re-run.',
            ),
          ],
        ),
      ),
    );
  }
}
