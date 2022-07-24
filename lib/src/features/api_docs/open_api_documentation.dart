import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

FutureOr<Response> openApiDocumentation(Request request) {
  final handler = SwaggerUI(
    'specs/open_api.yaml',
    deepLink: true,
  );
  return handler(request);
}
