import 'dart:async';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf/shelf.dart';

void main(List<String> arguments) async {
  final pipeline = Pipeline().addMiddleware(log());

  final server = await shelf.serve(
    pipeline.addHandler(_handler),
    '0.0.0.0',
    8000,
  );

  print('Server running on ${server.address.address}:${server.port}');
}

Middleware log() {
  return (Handler handler) {
    return (Request request) async {
      print('Requested: ${request.method} ${request.url}');
      final response = await handler(request);
      print('Responded: ${response.statusCode}');

      return response;
    };
  };
}

FutureOr<Response> _handler(request) {
  print(request);
  return Response(200, body: 'Hello, world!');
}
