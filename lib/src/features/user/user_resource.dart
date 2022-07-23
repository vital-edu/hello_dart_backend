import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes {
    return [
      Route.get('/user', _getUsers),
      Route.post('/user', _createUser),
      Route.get('/user/:id', _getUser),
      Route.put('/user/:id', _updateUser),
      Route.delete('/user/:id', _deleteUser),
    ];
  }

  Response _getUsers() {
    return Response.ok("[{'id': 1, 'name': 'John'}");
  }

  Response _getUser(ModularArguments args) {
    return Response.ok('User ${args.params['id']}');
  }

  Response _createUser(ModularArguments args) {
    return Response.ok('Created user ${args.data['id']}');
  }

  Response _updateUser(ModularArguments args) {
    return Response.ok('Updated user ${args.params['id']}');
  }

  Response _deleteUser(ModularArguments args) {
    return Response.ok('Deleted user ${args.params['id']}');
  }
}
