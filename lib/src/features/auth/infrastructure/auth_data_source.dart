import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/shared/list_extensions.dart';
import 'package:backend/src/features/auth/infrastructure/user_dto.dart';

abstract class AuthDataSource {
  Future<UserDto?> getUserByEmail(String email);
  Future<UserDto?> getUserById(String id);
  Future<UserDto?> updatePassword({
    required String userId,
    required String newPassword,
  });
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
  Future<UserDto?> updatePassword({
    required String userId,
    required String newPassword,
  }) async {
    final result = await database.query(
      'UPDATE "User" '
      'SET password = @password '
      'WHERE id = @id '
      'RETURNING id, role, password',
      parameters: {
        'id': userId,
        'password': newPassword,
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
