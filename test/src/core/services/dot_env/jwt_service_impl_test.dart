import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service_impl.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('token flow', () async {
    final mock = {
      'JWT_SECRET': 'asjdfklj39iezi23i',
    };

    final dotEnvService = DotEnvServices(mock: mock);
    final service = JwtServiceImpl(dotEnvService);

    final expirationTime = DateTime.now().add(Duration(seconds: 1));
    final expiration =
        Duration(milliseconds: expirationTime.millisecondsSinceEpoch);
    final token = service.generateToken(
        {'id': 'user_id_test', 'role': 'user', 'exp': expiration.inSeconds},
        'generate_auth_token');

    expect(
      () => service.verifyToken(token, 'generate_auth_token'),
      returnsNormally,
    );

    final payload = service.getPayload(token);
    expect(payload.keys, containsAll(['id', 'role', 'iat']));
    expect(payload['id'], equals('user_id_test'));
    expect(payload['role'], equals('user'));

    await Future.delayed(Duration(seconds: 1));
    expect(
      () => service.verifyToken(token, 'generate_auth_token'),
      throwsA(isA<JWTUndefinedError>()),
    );
  });
}
