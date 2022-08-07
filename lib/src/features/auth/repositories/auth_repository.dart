import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/core/shared/list_extensions.dart';
import 'package:backend/src/features/auth/domain/auth_exception.dart';
import 'package:backend/src/features/auth/domain/token_type.dart';
import 'package:backend/src/features/auth/domain/tokenization.dart';

class AuthRepository {
  final RequestExtractorService extractor;
  final JwtService jwt;
  final RemoteDatabase remoteDatabase;
  final CryptService crypt;
  final DotEnvServices env;

  const AuthRepository(
    this.extractor,
    this.jwt,
    this.remoteDatabase,
    this.crypt,
    this.env,
  );

  Future<Tokenization> login(UserCredentials credentials) async {
    final result = await remoteDatabase.query(
      'SELECT id, role, password FROM "User"'
      'WHERE email = @email',
      parameters: {
        'email': credentials.email,
      },
    );

    final user = result.safe(0)?['User'];
    if (user == null) {
      throw AuthException(401, 'Invalid credentials');
    }

    if (!crypt.match(credentials.password, user['password'])) {
      throw AuthException(
        401,
        'Invalid email or password',
      );
    }

    user.remove('password');
    return _generateAuthPayload(user);
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
