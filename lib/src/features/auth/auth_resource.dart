import 'dart:async';

import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/core/services/utils.dart';
import 'package:backend/src/core/shared/list_extensions.dart';
import 'package:backend/src/features/auth/guard/auth_guard_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('auth/login', _login),
        Route.get('auth/refresh_token', _refreshToken),
        Route.get(
          'auth/check_token',
          _checkToken,
          middlewares: [AuthGuardMiddleware()],
        ),
        Route.delete('auth/logout', _logout),
        Route.put('auth/password', _changePassword),
      ];

  FutureOr<Response> _login(Request request, Injector injector) async {
    final extractorService = injector.get<RequestExtractorService>();

    final credentials = extractorService.getBasicAuthorization(request);

    final remoteDatabase = injector.get<RemoteDatabase>();
    final result = await remoteDatabase.query(
      'SELECT password FROM "User"'
      'WHERE email = @email',
      parameters: {
        'email': credentials.email,
      },
    );

    final user = result.safe(0)?['User'];
    if (user == null) {
      return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
    }

    final cryptService = injector.get<CryptService>();

    if (!cryptService.match(credentials.password, user['password'])) {
      return Response(
        401,
        body: jsonEncode({'error': 'Invalid email or password'}),
      );
    }

    final jwtService = injector.get<JwtService>();
    final envService = injector.get<DotEnvServices>();

    final accessTokenExpirationInMinutes =
        int.parse(envService[EnvKey.accessTokenExpirationTimeInMinutes]);
    final accessTokenDuration =
        _expirationInMinutes(Duration(minutes: accessTokenExpirationInMinutes));

    final accessToken = jwtService.generateToken({
      ...user,
      'exp': accessTokenDuration,
    }, 'accessToken');

    final refreshTokenExpirationInMinutes =
        int.parse(envService[EnvKey.refreshTokenExpirationTimeInMinutes]);
    final refreshTokenDuration = _expirationInMinutes(
        Duration(minutes: refreshTokenExpirationInMinutes));
    final refreshToken = jwtService.generateToken({
      ...user,
      'exp': refreshTokenDuration,
    }, 'refreshToken');

    return Response.ok(jsonEncode({
      'access_token': accessToken,
      'refresh_token': refreshToken,
    }));
  }

  FutureOr<Response> _refreshToken(Injector injector) {
    return Response.ok(jsonEncode({}));
  }

  FutureOr<Response> _checkToken(Injector injector) {
    return Response.ok(jsonEncode({}));
  }

  FutureOr<Response> _logout(Injector injector) {
    return Response.ok(jsonEncode({}));
  }

  FutureOr<Response> _changePassword(Injector injector) {
    return Response.ok(jsonEncode({}));
  }

  int _expirationInMinutes(Duration duration) {
    final durationSinceEpoch =
        DateTime.now().add(duration).millisecondsSinceEpoch;
    return Duration(milliseconds: durationSinceEpoch).inSeconds;
  }
}
