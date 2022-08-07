import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/shared/list_extensions.dart';
import 'package:backend/src/features/auth/infrastructure/user_dto.dart';

abstract class AuthDataSource {
  Future<UserDto?> getUser(String email);
}

class AuthSqlDataSource implements AuthDataSource {
  final RemoteDatabase database;

  const AuthSqlDataSource(this.database);

  @override
  Future<UserDto?> getUser(String email) async {
    final result = await database.query(
      'SELECT id, role, password FROM "User"'
      'WHERE email = @email',
      parameters: {
        'email': email,
      },
    );

    final user = result.safe(0)?['User'];
    if (user == null) return null;

    return UserDto.fromMap(user);
  }
}
