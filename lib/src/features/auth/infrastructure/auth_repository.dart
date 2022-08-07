import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/features/auth/domain/auth_exception.dart';
import 'package:backend/src/features/auth/domain/token_type.dart';
import 'package:backend/src/features/auth/domain/tokenization.dart';
import 'package:backend/src/features/auth/infrastructure/auth_data_source.dart';
import 'package:backend/src/features/auth/infrastructure/user_dto.dart';

abstract class AuthRepository {
  Future<Tokenization> login(UserCredentials credentials);
  Future<Tokenization> refreshToken(String token);
  Future<Tokenization> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });
  Future<UserDto> getUser(String id);
}

class AuthRepositoryImpl implements AuthRepository {
  final RequestExtractorService extractor;
  final JwtService jwt;
  final AuthDataSource dataSource;
  final CryptService crypt;
  final DotEnvServices env;

  const AuthRepositoryImpl(
    this.extractor,
    this.jwt,
    this.dataSource,
    this.crypt,
    this.env,
  );

  @override
  Future<Tokenization> login(UserCredentials credentials) async {
    final user = await dataSource.getUserByEmail(credentials.email);
    if (user == null) {
      throw AuthException(401, 'Invalid credentials');
    }

    if (!crypt.match(credentials.password, user.password)) {
      throw AuthException(401, 'Invalid email or password');
    }

    return _generateToken(user);
  }

  @override
  Future<Tokenization> refreshToken(String token) async {
    final String? userId = jwt.getPayload(token)['id'];

    if (userId == null) {
      throw AuthException(401, 'Invalid credentials');
    }

    final user = await getUser(userId);
    return _generateToken(user);
  }

  @override
  Future<Tokenization> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = await getUser(userId);

    if (!crypt.match(currentPassword, user.password)) {
      throw AuthException(401, 'Invalid password');
    }

    final newEncryptedPassword = crypt.encrypt(newPassword);
    final updatedUser = await dataSource.updatePassword(
      userId: userId,
      newPassword: newEncryptedPassword,
    );

    if (updatedUser == null) {
      throw AuthException(500, 'Unknown error');
    }

    return _generateToken(updatedUser);
  }

  @override
  Future<UserDto> getUser(String id) async {
    final user = await dataSource.getUserById(id);
    if (user == null) {
      throw AuthException(401, 'Invalid credentials');
    } else {
      return user;
    }
  }

  Tokenization _generateToken(UserDto user) {
    final payload = user.toMap();
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
