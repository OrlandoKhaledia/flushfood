import 'package:flutter/material.dart';
import 'tutorial_service.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const TutorialOverlay({super.key, required this.onClose});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  final List<Rect> _targets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _collectTargets());
  }

  void _collectTargets() {
    final keys = TutorialService.instance.getAllKeys();
    final List<Rect> rects = [];
    for (final entry in keys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final pos = box.localToGlobal(Offset.zero);
      rects.add(Rect.fromLTWH(pos.dx, pos.dy, box.size.width, box.size.height));
    }

    setState(() => _targets.clear());
    setState(() => _targets.addAll(rects));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Stack(
          children: [
            // highlight boxes for each target
            for (final r in _targets)
              Positioned(
                left: r.left - 6,
                top: r.top - 6,
                width: r.width + 12,
                height: r.height + 12,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellowAccent, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            Positioned(
              left: 16,
              right: 16,
              top: 80,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Welcome to flashfood', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('• Tap + to quickly add items'),
                      Text('• View expiring items in Notifications'),
                      Text('• Use the Shopping tab to manage low-stock items'),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              bottom: 24,
              right: 16,
              child: ElevatedButton(
                onPressed: widget.onClose,
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
