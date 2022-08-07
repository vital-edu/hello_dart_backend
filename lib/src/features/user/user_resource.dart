import 'package:backend/src/core/cuid.dart';
import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/services/utils.dart';
import 'package:backend/src/features/auth/guard/auth_guard_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes {
    return [
      Route.get(
        '',
        _getUsers,
        middlewares: [AuthGuardMiddleware()],
      ),
      Route.post('', _createUser),
      Route.get(
        ':id',
        _getUser,
        middlewares: [AuthGuardMiddleware()],
      ),
      Route.put(
        ':id',
        _updateUser,
        middlewares: [AuthGuardMiddleware()],
      ),
      Route.delete(
        ':id',
        _deleteUser,
        middlewares: [AuthGuardMiddleware()],
      ),
    ];
  }

  Future<Response> _getUsers(Injector injector) async {
    final database = injector.get<RemoteDatabase>();

    final result = await database.query(
      'SELECT id, name, email, role, "createdAt", "updatedAt" FROM "User"',
    );
    final users = result.map((e) => e['User']).toList();
    return Response.ok(jsonEncode(users));
  }

  Future<Response> _getUser(ModularArguments args, Injector injector) async {
    final id = args.params['id'];
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Missing id'}));
    }

    final database = injector<RemoteDatabase>();
    final result = await database.query(
      'SELECT id, name, email, role, "createdAt", "updatedAt" '
      'FROM "User" WHERE id = @id',
      parameters: {'id': id},
    );

    return result.first['User'] == null
        ? Response.notFound(jsonEncode({'error': 'User not found'}))
        : Response.ok(jsonEncode(result.first['User']));
  }

  Future<Response> _createUser(ModularArguments args, Injector injector) async {
    final params = (args.data as Map).cast<String, String>();
    final allowedParams = ['name', 'email', 'password'];

    params.removeWhere((key, value) => !allowedParams.contains(key));
    params['id'] = newCuid();

    params['password'] = injector<CryptService>().encrypt(params['password']!);

    final query = 'INSERT INTO "User"(id, name, email, password) '
        'VALUES (@id, @name, @email, @password) '
        'RETURNING id, name, email, role, "createdAt", "updatedAt"';
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(query, parameters: params);

    return result.first['User'] == null
        ? Response.badRequest(body: {'error': 'Invalid data'})
        : Response.ok(jsonEncode(result.first['User']));
  }

  Future<Response> _updateUser(ModularArguments args, Injector injector) async {
    final userId = args.params['id'];
    final params = (args.data as Map).cast<String, String>();
    final allowedParams = ['name', 'email', 'password'];

    params.removeWhere((key, value) => !allowedParams.contains(key));
    final changes = params.keys.map((key) => '$key = @$key').join(', ');

    params['id'] = userId;
    params['password'] = injector<CryptService>().encrypt(params['password']!);

    final query = 'UPDATE "User" '
        'SET $changes '
        'WHERE id = @id '
        'RETURNING id, name, email, role, "createdAt", "updatedAt"';
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(query, parameters: params);

    return result.first['User'] == null
        ? Response.badRequest(body: {'error': 'Invalid data'})
        : Response.ok(jsonEncode(result.first['User']));
  }

  Future<Response> _deleteUser(ModularArguments args, Injector injector) async {
    final query = 'DELETE FROM "User" WHERE id = @id '
        'RETURNING id, name, email, role, "createdAt", "updatedAt"';
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(query,
        parameters: args.params.cast<String, String>());

    return result.first['User'] == null
        ? Response.badRequest(body: {'error': 'Invalid data'})
        : Response.ok(jsonEncode(result.first['User']));
  }
}
