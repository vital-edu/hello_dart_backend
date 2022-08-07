import 'dart:async';

import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/core/services/utils.dart';
import 'package:backend/src/core/shared/list_extensions.dart';
import 'package:backend/src/features/auth/domain/auth_exception.dart';
import 'package:backend/src/features/auth/domain/token_type.dart';
import 'package:backend/src/features/auth/guard/auth_guard_middleware.dart';
import 'package:backend/src/features/auth/infrastructure/auth_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/login', _login),
        Route.get('/refresh_token', _refreshToken, middlewares: [
          AuthGuardMiddleware(tokenType: TokenType.refreshToken),
        ]),
        Route.get('/check_token', _checkToken, middlewares: [
          AuthGuardMiddleware(),
        ]),
        Route.delete('/logout', _logout),
        Route.put('/password', _changePassword, middlewares: [
          AuthGuardMiddleware(),
        ]),
      ];

  FutureOr<Response> _login(Request request, Injector injector) async {
    final authRepository = injector.get<AuthRepository>();
    final extractorService = injector.get<RequestExtractorService>();
    final credentials = extractorService.getBasicAuthorization(request);

    try {
      final result = await authRepository.login(credentials);
      return Response.ok(result.toJson());
    } on AuthException catch (error) {
      return Response(error.code, body: error.toJson());
    }
  }

  FutureOr<Response> _refreshToken(Injector injector, Request request) async {
    final extractorService = injector.get<RequestExtractorService>();
    final jwtService = injector.get<JwtService>();

    final token = extractorService.getAuthorizationBearer(request);
    final payload = jwtService.getPayload(token);

    final remoteDatabase = injector.get<RemoteDatabase>();
    final result = await remoteDatabase.query(
      'SELECT id, role FROM "User"'
      'WHERE id = @id',
      parameters: {
        'id': payload['id'],
      },
    );

    final user = result.safe(0)?['User'];
    if (user == null) {
      return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
    }

    return Response.ok(jsonEncode(_generateAuthPayload(user, injector)));
  }

  FutureOr<Response> _checkToken(Injector injector) {
    return Response.ok(jsonEncode({}));
  }

  FutureOr<Response> _logout(Injector injector) {
    return Response.ok(jsonEncode({}));
  }

  FutureOr<Response> _changePassword(
      Injector injector, Request request, ModularArguments args) async {
    final newRawPassword = args.data['new_password'];
    final currentRawPassword = args.data['password'];

    if (newRawPassword == null || currentRawPassword == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'Missing password'}));
    }

    if (newRawPassword == currentRawPassword) {
      return Response.badRequest(
          body: jsonEncode({'error': 'New password must be different'}));
    }

    final extractorService = injector.get<RequestExtractorService>();
    final token = extractorService.getAuthorizationBearer(request);

    final jwtService = injector.get<JwtService>();
    final payload = jwtService.getPayload(token);

    final remoteDatabase = injector.get<RemoteDatabase>();
    final searchResult = await remoteDatabase.query(
      'SELECT id, role, password FROM "User" '
      'WHERE id = @id',
      parameters: {
        'id': payload['id'],
      },
    );

    var user = searchResult.safe(0)?['User'];
    if (user == null) {
      return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
    }

    final cryptService = injector.get<CryptService>();
    if (!cryptService.match(currentRawPassword, user['password'])) {
      return Response(
        401,
        body: jsonEncode({'error': 'Invalid email or password'}),
      );
    }

    final newPassword = cryptService.encrypt(newRawPassword);
    final updateResult = await remoteDatabase.query(
      'UPDATE "User" '
      'SET password = @password '
      'WHERE id = @id '
      'RETURNING id, role',
      parameters: {
        'id': payload['id'],
        'password': newPassword,
      },
    );

    user = updateResult.safe(0)?['User'];
    if (user == null) {
      return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
    }

    return Response(401,
        body: jsonEncode(_generateAuthPayload(user, injector)));
  }

  int _expirationInMinutes(Duration duration) {
    final durationSinceEpoch =
        DateTime.now().add(duration).millisecondsSinceEpoch;
    return Duration(milliseconds: durationSinceEpoch).inSeconds;
  }

  Map<String, dynamic> _generateAuthPayload(
      Map<String, dynamic> payload, Injector injector) {
    final jwtService = injector.get<JwtService>();
    final envService = injector.get<DotEnvServices>();

    final accessTokenExpirationInMinutes =
        int.parse(envService[EnvKey.accessTokenExpirationTimeInMinutes]);
    final accessTokenDuration =
        _expirationInMinutes(Duration(minutes: accessTokenExpirationInMinutes));

    final accessToken = jwtService.generateToken({
      ...payload,
      'exp': accessTokenDuration,
    }, TokenType.accessToken.value);

    final refreshTokenExpirationInMinutes =
        int.parse(envService[EnvKey.refreshTokenExpirationTimeInMinutes]);
    final refreshTokenDuration = _expirationInMinutes(
        Duration(minutes: refreshTokenExpirationInMinutes));
    final refreshToken = jwtService.generateToken({
      ...payload,
      'exp': refreshTokenDuration,
    }, TokenType.refreshToken.value);

    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
