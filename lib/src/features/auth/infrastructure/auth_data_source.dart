import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/shared/list_extensions.dart';
import 'package:backend/src/features/auth/infrastructure/user_dto.dart';

abstract class AuthDataSource {
  Future<UserDto?> getUserByEmail(String email);
  Future<UserDto?> getUserById(String id);
}

class AuthSqlDataSource implements AuthDataSource {
  final RemoteDatabase database;

  const AuthSqlDataSource(this.database);

  @override
  Future<UserDto?> getUserByEmail(String email) async {
    final result = await database.query(
      'SELECT id, role, password FROM "User"'
      'WHERE email = @email',
      parameters: {
        'email': email,
      },
    );

    return _processResult(result);
  }

  @override
  Future<UserDto?> getUserById(String id) async {
    final result = await database.query(
      'SELECT id, role, password FROM "User"'
      'WHERE id = @id',
      parameters: {
        'id': id,
      },
    );

    return _processResult(result);
  }

  UserDto? _processResult(List<Map<String, Map<String, dynamic>>> result) {
    final user = result.safe(0)?['User'];
    if (user == null) return null;

    return UserDto.fromMap(user);
  }
}
