import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('expect to retrieve env variable', () {
    final mock = {
      'JWT_SECRET': 'test value',
    };

    final service = DotEnvServices(mock: mock);
    expect(service[EnvKey.jwtSecret], 'test value');
  });
}
