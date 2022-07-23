import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes {
    return [
      Route.get('/', () => Response.ok('Initial Route')),
      Route.get('/login', () => Response.ok('Login Route')),
    ];
  }
}
