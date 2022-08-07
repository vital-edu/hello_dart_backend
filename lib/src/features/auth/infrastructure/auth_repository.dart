import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/features/auth/domain/auth_exception.dart';
import 'package:backend/src/features/auth/domain/token_type.dart';
import 'package:backend/src/features/auth/domain/tokenization.dart';
import 'package:backend/src/features/auth/infrastructure/auth_data_source.dart';

class AuthRepository {
  final RequestExtractorService extractor;
  final JwtService jwt;
  final AuthDataSource dataSource;
  final CryptService crypt;
  final DotEnvServices env;

  const AuthRepository(
    this.extractor,
    this.jwt,
    this.dataSource,
    this.crypt,
    this.env,
  );

  Future<Tokenization> login(UserCredentials credentials) async {
    final user = await dataSource.getUser(credentials.email);
    if (user == null) {
      throw AuthException(401, 'Invalid credentials');
    }

    if (!crypt.match(credentials.password, user.password)) {
      throw AuthException(
        401,
        'Invalid email or password',
      );
    }

    return _generateAuthPayload(user.toMap());
  }

  Tokenization _generateAuthPayload(Map<String, dynamic> payload) {
    final accessTokenExpirationInMinutes =
        int.parse(env[EnvKey.accessTokenExpirationTimeInMinutes]);
    final accessTokenDuration =
        _expirationInMinutes(Duration(minutes: accessTokenExpirationInMinutes));

    final accessToken = jwt.generateToken({
      ...payload,
      'exp': accessTokenDuration,
    }, TokenType.accessToken.value);

    final refreshTokenExpirationInMinutes =
        int.parse(env[EnvKey.refreshTokenExpirationTimeInMinutes]);
    final refreshTokenDuration = _expirationInMinutes(
        Duration(minutes: refreshTokenExpirationInMinutes));
    final refreshToken = jwt.generateToken({
      ...payload,
      'exp': refreshTokenDuration,
    }, TokenType.refreshToken.value);

    return Tokenization(accessToken: accessToken, refreshToken: refreshToken);
  }

  int _expirationInMinutes(Duration duration) {
    final durationSinceEpoch =
        DateTime.now().add(duration).millisecondsSinceEpoch;
    return Duration(milliseconds: durationSinceEpoch).inSeconds;
  }
}
