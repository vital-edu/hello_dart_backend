import 'dart:convert';

import 'package:shelf/shelf.dart';

class RequestExtractorService {
  const RequestExtractorService();

  String getAuthorizationBearer(Request request) {
    try {
      final authorization = request.headers['authorization']!;
      final components = authorization.split(' ');
      return components.last;
    } catch (error) {
      throw 'Invalid authorization header';
    }
  }

  UserCredentials getBasicAuthorization(Request request) {
    try {
      final authorization = request.headers['authorization'] ?? '';
      final encodedCredentials = authorization.split(' ').last;
      final credentials =
          String.fromCharCodes(base64Decode(encodedCredentials));
      final components = credentials.split(':');

      return UserCredentials(
        email: components.first,
        password: components.last,
      );
    } catch (error) {
      throw 'Invalid authorization header';
    }
  }
}

class UserCredentials {
  final String email;
  final String password;

  UserCredentials({required this.email, required this.password});
}
