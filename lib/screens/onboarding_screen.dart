import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Skip'),
          )
        ],
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          _buildPage('Add items quickly', 'assets/images/onboarding1.svg'),
          _buildPage('Track expiry & reduce waste', 'assets/images/onboarding2.svg'),
          _buildPage('Shopping lists & analytics', 'assets/images/onboarding3.svg'),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: List.generate(3, (i) => _indicator(i == _page)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_page < 2) {
                  _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  // Mark onboarding complete
                  final nav = Navigator.of(context);
                  final box = await Hive.openBox('app_settings');
                  await box.put('onboarding_completed', true);
                  nav.pushReplacementNamed('/');
                }
              },
              child: Text(_page < 2 ? 'Next' : 'Done'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String title, String asset) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(asset, height: 220),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _indicator(bool active) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: active ? 16 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: active ? Theme.of(context).colorScheme.primary : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
      );
}
