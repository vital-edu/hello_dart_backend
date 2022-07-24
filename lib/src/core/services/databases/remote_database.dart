abstract class RemoteDatabase {
  Future<List<Map<String, Map<String, dynamic>>>> query(
    query, {
    Map<String, String> parameters = const {},
  });
}
