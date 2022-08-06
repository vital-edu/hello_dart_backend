import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/core/services/utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthGuardMiddleware extends ModularMiddleware {
  @override
  Handler call(Handler handler, [ModularRoute? route]) {
    return (Request request) {
      final extractorService = Modular.get<RequestExtractorService>();
      final jwtService = Modular.get<JwtService>();

      try {
        final token = extractorService.getAuthorizationBearer(request);
        jwtService.verifyToken(token, 'accessToken');
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
