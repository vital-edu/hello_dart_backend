import 'package:backend/src/features/auth/auth_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthModule extends Module {
  @override
  List<ModularRoute> get routes {
    return [
      Route.resource(AuthResource()),
    ];
  }
}
