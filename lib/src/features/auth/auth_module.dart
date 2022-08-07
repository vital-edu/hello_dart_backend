import 'package:backend/src/features/auth/repositories/auth_repository.dart';
import 'package:backend/src/features/auth/resources/auth_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthModule extends Module {
  @override
  List<Bind<Object>> get binds {
    return [
      Bind.singleton((i) => AuthRepository(i(), i(), i(), i(), i())),
    ];
  }

  @override
  List<ModularRoute> get routes {
    return [
      Route.resource(AuthResource()),
    ];
  }
}
