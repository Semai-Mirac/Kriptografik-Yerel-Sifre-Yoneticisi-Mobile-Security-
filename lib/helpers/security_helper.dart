import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecurityHelper {
  static String encryptData(String plainText, String masterPassword) {
    if (masterPassword.trim().isEmpty) {
      throw const FormatException('Master password boş olamaz.');
    }

    final keyBytes = sha256.convert(utf8.encode(masterPassword)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes));

    final random = Random.secure();
    final ivBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final iv = encrypt.IV(Uint8List.fromList(ivBytes));

    final aes = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    final encrypted = aes.encrypt(plainText, iv: iv);
    final payload = <int>[...iv.bytes, ...encrypted.bytes];
    return base64Encode(payload);
  }

  static String decryptData(String cipherText, String masterPassword) {
    if (masterPassword.trim().isEmpty) {
      throw const FormatException('Master password boş olamaz.');
    }

    final payload = base64Decode(cipherText);
    if (payload.length < 17) {
      throw const FormatException('Geçersiz şifreli veri.');
    }

    final ivBytes = payload.sublist(0, 16);
    final encryptedBytes = payload.sublist(16);

    final keyBytes = sha256.convert(utf8.encode(masterPassword)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV(Uint8List.fromList(ivBytes));

    final aes = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    try {
      return aes.decrypt(
        encrypt.Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: iv,
      );
    } catch (_) {
      throw const FormatException('Geçersiz master şifre veya bozuk veri.');
    }
  }
}
