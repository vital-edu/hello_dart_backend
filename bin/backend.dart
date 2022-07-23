import 'dart:async';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf/shelf.dart';

void main(List<String> arguments) {
  final server = shelf.serve(_handler, '0.0.0.0', 8000);

  server.then((_) => print('Server running on ${_.address.address}:${_.port}'));
}

FutureOr<Response> _handler(request) {
  print(request);
  return Response(200, body: 'Hello, world!');
}
