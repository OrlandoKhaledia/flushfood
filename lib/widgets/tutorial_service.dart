import 'package:flutter/widgets.dart';

class TutorialService {
  TutorialService._private();

  static final TutorialService instance = TutorialService._private();

  final Map<String, GlobalKey> _keys = {};

  void registerKey(String name, GlobalKey key) {
    _keys[name] = key;
  }

  GlobalKey? getKey(String name) => _keys[name];

  Map<String, GlobalKey> getAllKeys() => Map.unmodifiable(_keys);
}
