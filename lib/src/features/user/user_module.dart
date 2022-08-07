import 'package:backend/src/features/user/user_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';

class UserModule extends Module {
  @override
  List<ModularRoute> get routes {
    return [
      Route.resource(UserResource()),
    ];
  }
}
