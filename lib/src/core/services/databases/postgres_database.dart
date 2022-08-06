import 'dart:async';

import 'package:backend/src/core/services/databases/remote_database.dart';
import 'package:backend/src/core/services/dot_env/dot_env_services.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf_modular/shelf_modular.dart';

class PostgresDatabase implements RemoteDatabase, Disposable {
  final DotEnvServices dotEnvServices;
  final Completer<PostgreSQLConnection> _completer = Completer();

  PostgresDatabase(this.dotEnvServices) {
    _init();
  }

  Future<void> _init() async {
    final dbUriString = dotEnvServices[EnvKey.databaseUrl];

    final uri = Uri.parse(dbUriString);
    final port = uri.port;
    final host = uri.host;
    final database = uri.pathSegments.first;
    final usernameAndPasswird = uri.userInfo.split(':');
    final username = usernameAndPasswird.first;
    final password = usernameAndPasswird.last;

    final connection = PostgreSQLConnection(
      host,
      port,
      database,
      username: username,
      password: password,
    );

    await connection.open();
    _completer.complete(connection);
  }

  @override
  Future<List<Map<String, Map<String, dynamic>>>> query(
    query, {
    Map<String, String> parameters = const {},
  }) async {
    final connection = await _completer.future;
    return await connection.mappedResultsQuery(
      query,
      substitutionValues: parameters,
    );
  }

  @override
  void dispose() async {
    final connection = await _completer.future;
    await connection.close();
  }
}
