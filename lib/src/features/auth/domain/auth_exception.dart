import 'dart:convert';

class AuthException {
  final int code;
  final String message;
  final StackTrace? stackTrace;

  AuthException(this.code, this.message, {this.stackTrace});

  Map<String, Object> toMap() {
    return {
      'error': message,
    };
  }

  String toJson() => json.encode(toMap());
}
