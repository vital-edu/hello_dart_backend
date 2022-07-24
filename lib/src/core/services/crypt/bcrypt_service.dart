import 'package:backend/src/core/services/crypt/crypt_service.dart';
import 'package:bcrypt/bcrypt.dart';

class BCryptService implements CryptService {
  @override
  String encrypt(String text) => BCrypt.hashpw(text, BCrypt.gensalt());

  @override
  bool match(String text, String hash) => BCrypt.checkpw(text, hash);
}
