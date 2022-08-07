import 'dart:async';

import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/core/services/utils.dart';
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
    final authRepository = injector.get<AuthRepository>();

    final token = extractorService.getAuthorizationBearer(request);
    try {
      final result = await authRepository.refreshToken(token);
      return Response.ok(result.toJson());
    } on AuthException catch (error) {
      return Response(error.code, body: error.toJson());
    }
  }

  FutureOr<Response> _checkToken(Injector injector) {
    return Response.ok(jsonEncode({}));
  }

  FutureOr<Response> _logout(Injector injector) {
    return Response.ok(jsonEncode({}));
  }

  FutureOr<Response> _changePassword(
      Injector injector, Request request, ModularArguments args) async {
    final newPassword = args.data['new_password'];
    final currentPassword = args.data['password'];

    if (currentPassword == null || newPassword == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'Missing password'}));
    }

    if (currentPassword == newPassword) {
      return Response.badRequest(
          body: jsonEncode({'error': 'New password must be different'}));
    }

    final extractorService = injector.get<RequestExtractorService>();
    final token = extractorService.getAuthorizationBearer(request);

    final authRepository = injector.get<AuthRepository>();
    try {
      final result = await authRepository.updatePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Response.ok(result.toJson());
    } on AuthException catch (error) {
      return Response(error.code, body: error.message);
    }
  }
}
