import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/core/services/utils.dart';
import 'package:backend/src/features/auth/domain/token_type.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthGuardMiddleware extends ModularMiddleware {
  final List<String> _roles;
  final TokenType _tokenType;

  const AuthGuardMiddleware({
    List<String> roles = const [],
    TokenType tokenType = TokenType.accessToken,
  })  : _roles = roles,
        _tokenType = tokenType;

  @override
  Handler call(Handler handler, [ModularRoute? route]) {
    return (Request request) {
      final extractorService = Modular.get<RequestExtractorService>();
      final jwtService = Modular.get<JwtService>();

      try {
        final token = extractorService.getAuthorizationBearer(request);
        jwtService.verifyToken(token, _tokenType.value);

        final payload = jwtService.getPayload(token);
        if (_roles.isNotEmpty && !_roles.contains(payload['role'])) {
          throw 'User not authorized';
        }

        return handler(request);
      } catch (error) {
        return Response(
          401,
          body: jsonEncode({
            'error': '$error',
          }),
        );
      }
    };
  }
}
