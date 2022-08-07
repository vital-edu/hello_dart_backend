import 'package:backend/src/core/core_module.dart';
import 'package:backend/src/features/api_docs/open_api_documentation.dart';
import 'package:backend/src/features/auth/auth_module.dart';
import 'package:backend/src/features/user/user_module.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  List<ModularRoute> get routes {
    return [
      Route.get('/', () => Response.ok('Hello Wourld!')),
      Route.get('/docs/**', openApiDocumentation),
      Route.module('/auth', module: AuthModule()),
      Route.module('/user', module: UserModule()),
    ];
  }
}
