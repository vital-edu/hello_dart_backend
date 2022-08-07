import 'package:backend/src/core/services/utils.dart';

class AuthException {
  final int code;
  final String message;
  final StackTrace? stackTrace;

  AuthException(this.code, this.message, {this.stackTrace});

  Map<String, Object> toMap() {
    return {
      'code': code,
      'message': message,
    };
  }

  String toJson() => jsonEncode(toMap());
}
