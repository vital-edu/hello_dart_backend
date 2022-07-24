abstract class CryptService {
  /// Encrypts a string.
  String encrypt(String text);

  /// Verify if text matches hash.
  bool match(String text, String hash);
}
