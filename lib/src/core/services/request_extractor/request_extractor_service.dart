import 'dart:convert';

import 'package:shelf/shelf.dart';

class RequestExtractorService {
  const RequestExtractorService();

  String getAuthorizationBearer(Request request) {
    final authorization = request.headers['authorization'] ?? '';
    final components = authorization.split(' ');

    return components.last;
  }

  UserCredentials getBasicAuthorization(Request request) {
    final authorization = request.headers['authorization'] ?? '';
    final encodedCredentials = authorization.split(' ').last;
    final credentials = String.fromCharCodes(base64Decode(encodedCredentials));
    final components = credentials.split(':');

    return UserCredentials(email: components.first, password: components.last);
  }
}

class UserCredentials {
  final String email;
  final String password;

  UserCredentials({required this.email, required this.password});
}
