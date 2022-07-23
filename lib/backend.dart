import 'dart:async';

import 'package:backend/src/app_module.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

Future<Handler> startShelfModular() async {
  return Modular(module: AppModule(), middlewares: [
    logRequests(),
  ]);
}
