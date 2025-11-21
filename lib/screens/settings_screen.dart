import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings_provider.dart';
import 'onboarding_screen.dart';
import '../widgets/tutorial_overlay.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (context, settings, _) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(settings.themeMode.toString().split('.').last),
              trailing: DropdownButton<AppThemeMode>(
                value: settings.themeMode,
                items: AppThemeMode.values
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.toString().split('.').last)))
                    .toList(),
                onChanged: (v) => settings.setTheme(v ?? AppThemeMode.system),
              ),
            ),
            SwitchListTile(
              title: const Text('Enable notifications'),
              value: settings.notificationsEnabled,
              onChanged: (v) => settings.setNotificationsEnabled(v),
            ),
            ListTile(
              title: const Text('View Onboarding'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen())),
            ),
            ListTile(
              title: const Text('Show Tutorial'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TutorialOverlay(onClose: () => Navigator.of(context).pop()))),
            ),
          ],
        ),
      );
    });
  }
}
