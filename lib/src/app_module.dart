import 'package:backend/src/core/services/databases/postgres_database.dart';
import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:backend/src/features/user/user_resource.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds {
    return [
      Bind.instance<DotEnvServices>(DotEnvServices.instance),
      Bind.singleton<RemoteDatabase>(
        (i) => PostgresDatabase(i()),
      ),
    ];
  }

  @override
  List<ModularRoute> get routes {
    return [
      Route.get('/', () => Response.ok('Hello Wourld!')),
      Route.resource(UserResource()),
    ];
  }
}
