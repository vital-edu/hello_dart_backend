import 'dart:io';

class DotEnvServices {
  final Map<String, String> _map = {};

  DotEnvServices._() {
    final file = File('.env');
    final lines = file.readAsLinesSync();

    for (final line in lines) {
      final parts = line.split('=');
      _map[parts[0]] = parts[1];
    }
  }

  static final instance = DotEnvServices._();

  String? operator [](String key) => _map[key];
}
