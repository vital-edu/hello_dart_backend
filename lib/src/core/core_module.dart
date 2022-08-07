import 'package:backend/src/core/services/crypt/bcrypt_service.dart';
import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:backend/src/core/services/databases/postgres_database.dart';
import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/core/services/jwt/jwt_service.dart';
import 'package:backend/src/core/services/jwt/jwt_service_impl.dart';
import 'package:backend/src/core/services/request_extractor/request_extractor_service.dart';
import 'package:shelf_modular/shelf_modular.dart';

class CoreModule extends Module {
  @override
  List<Bind<Object>> get binds {
    return [
      Bind.singleton<DotEnvServices>((_) => DotEnvServices(), export: true),
      Bind.singleton<RemoteDatabase>(
        (i) => PostgresDatabase(i()),
        export: true,
      ),
      Bind.singleton<CryptService>((_) => BCryptService(), export: true),
      Bind.singleton<JwtService>((i) => JwtServiceImpl(i()), export: true),
      Bind.singleton<RequestExtractorService>(
        (_) => RequestExtractorService(),
        export: true,
      ),
    ];
  }
}
