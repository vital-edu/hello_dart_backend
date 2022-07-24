import 'dart:async';

import 'package:backend/src/core/services/utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        Route.post('auth/login', _login),
        Route.get('auth/refresh_token', _refreshToken),
        Route.get('auth/check_token', _checkToken),
        Route.delete('auth/logout', _logout),
        Route.put('auth/password', _changePassword),
      ];

  FutureOr<Response> _login(Injector injector) {
    return Response.ok(jsonEncode({}));
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
}
