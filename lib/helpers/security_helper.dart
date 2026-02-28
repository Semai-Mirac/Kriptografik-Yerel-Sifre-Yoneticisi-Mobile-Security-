import 'dart:convert';

class SecurityHelper {
  static String encryptData(String plainText, String masterPassword) {
    final key = utf8.encode(masterPassword);
    if (key.isEmpty) {
      throw const FormatException('Master password boş olamaz.');
    }

    final payload = utf8.encode('SECURE::${plainText}');
    final encrypted = List<int>.generate(
      payload.length,
      (index) => payload[index] ^ key[index % key.length],
    );
    return base64Encode(encrypted);
  }

  static String decryptData(String cipherText, String masterPassword) {
    final key = utf8.encode(masterPassword);
    if (key.isEmpty) {
      throw const FormatException('Master password boş olamaz.');
    }

    final encrypted = base64Decode(cipherText);
    final decrypted = List<int>.generate(
      encrypted.length,
      (index) => encrypted[index] ^ key[index % key.length],
    );

    final result = utf8.decode(decrypted);
    if (!result.startsWith('SECURE::')) {
      throw const FormatException('Geçersiz master şifre veya bozuk veri.');
    }

    return result.replaceFirst('SECURE::', '');
  }
}

