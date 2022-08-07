import 'package:backend/src/features/auth/infrastructure/auth_data_source.dart';
import 'package:backend/src/features/auth/infrastructure/auth_repository.dart';
import 'package:backend/src/features/auth/resources/auth_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthModule extends Module {
  @override
  List<Bind<Object>> get binds {
    return [
      Bind.singleton<AuthRepository>(
        (i) => AuthRepositoryImpl(i(), i(), i(), i(), i()),
      ),
      Bind.singleton<AuthDataSource>((i) => AuthSqlDataSource(i())),
    ];
  }

  @override
  List<ModularRoute> get routes {
    return [
      Route.resource(AuthResource()),
    ];
  }
}
