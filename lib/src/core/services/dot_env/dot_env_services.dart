import 'dart:io';

class DotEnvServices {
  final Map<EnvKey, String> _map = {};

  DotEnvServices({Map<String, String>? mock}) {
    if (mock != null) {
      _map.addAll(mock.map((key, value) => MapEntry(EnvKey.from(key), value)));
      return;
    }

    _init();
  }

  void _init() {
    final file = File('.env');
    final lines = file.readAsLinesSync();

    for (final line in lines) {
      final parts = line.split('=');
      _map[EnvKey.from(parts[0])] = parts[1];
    }
  }

  String operator [](EnvKey key) => _map[key]!;
}

enum EnvKey {
  databaseUrl('DATABASE_URL'),
  jwtSecret('JWT_SECRET'),
  accessTokenExpirationTimeInMinutes('ACCESS_TOKEN_EXPIRATION_TIME_IN_MINUTES'),
  refreshTokenExpirationTimeInMinutes('TOKEN_EXPIRATION_TIME_IN_MINUTES');

  final String value;

  const EnvKey(this.value);

  static EnvKey from(String value) {
    switch (value) {
      case 'DATABASE_URL':
        return EnvKey.databaseUrl;
      case 'JWT_SECRET':
        return EnvKey.jwtSecret;
      case 'ACCESS_TOKEN_EXPIRATION_TIME_IN_MINUTES':
        return EnvKey.accessTokenExpirationTimeInMinutes;
      case 'REFRESH_TOKEN_EXPIRATION_TIME_IN_MINUTES':
        return EnvKey.refreshTokenExpirationTimeInMinutes;
      default:
        throw ArgumentError('Unknown enum value: $value');
    }
  }
}
