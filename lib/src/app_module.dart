import 'package:backend/src/features/user/user_resource.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes {
    return [
      Route.get('/', () => Response.ok('Hello Wourld!')),
      Route.resource(UserResource()),
    ];
  }
}
