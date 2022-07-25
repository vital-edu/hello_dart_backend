import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtServiceImpl implements JwtService {
  final SecretKey _secret;

  JwtServiceImpl(DotEnvServices dotEnvServices)
      : _secret = SecretKey(dotEnvServices['JWT_SECRET']!);

  @override
  String generateToken(Map info, String audience) {
    return JWT(info, audience: Audience.one(audience)).sign(_secret);
  }

  @override
  Map getPayload(String token) {
    return JWT.verify(token, _secret).payload;
  }

  @override
  void verifyToken(String token, String audience) {
    JWT.verify(token, _secret, audience: Audience.one(audience));
  }
}
