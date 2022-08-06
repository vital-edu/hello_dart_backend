import 'package:backend/src/core/services/crypt/bcrypt_service.dart';
import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:backend/src/core/services/databases/postgres_database.dart';
import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/jwt/jwt_service_impl.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:backend/src/features/api_docs/open_api_documentation.dart';
import 'package:backend/src/features/auth/auth_resource.dart';
import 'package:backend/src/features/user/user_resource.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds {
    return [
      Bind.singleton<DotEnvServices>((_) => DotEnvServices()),
      Bind.singleton<RemoteDatabase>(
        (i) => PostgresDatabase(i()),
      ),
      Bind.singleton<CryptService>((_) => BCryptService()),
      Bind.singleton<JwtService>((i) => JwtServiceImpl(i())),
      Bind.singleton<RequestExtractorService>((_) => RequestExtractorService()),
    ];
  }

  @override
  List<ModularRoute> get routes {
    return [
      Route.get('/', () => Response.ok('Hello Wourld!')),
      Route.get('/docs/**', openApiDocumentation),
      Route.resource(AuthResource()),
      Route.resource(UserResource()),
    ];
  }
}
