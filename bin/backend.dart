import 'dart:async';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf/shelf.dart';

void main(List<String> arguments) async {
  final server = await shelf.serve(_handler, '0.0.0.0', 8000);

  print('Server running on ${server.address.address}:${server.port}');
}

FutureOr<Response> _handler(request) {
  print(request);
  return Response(200, body: 'Hello, world!');
}
