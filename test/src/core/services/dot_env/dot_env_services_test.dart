import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('expect to retrieve env variable', () {
    final mock = {
      'TEST_KEY': 'test value',
    };

    final service = DotEnvServices(mock: mock);
    expect(service['TEST_KEY'], 'test value');
  });
}
