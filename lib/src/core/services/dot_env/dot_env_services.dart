import 'dart:io';

class DotEnvServices {
  final Map<String, String> _map = {};

  DotEnvServices({Map<String, String>? mock}) {
    if (mock != null) {
      _map.addAll(mock);
      return;
    }

    _init();
  }

  void _init() {
    final file = File('.env');
    final lines = file.readAsLinesSync();

    for (final line in lines) {
      final parts = line.split('=');
      _map[parts[0]] = parts[1];
    }
  }

  String? operator [](String key) => _map[key];
}
