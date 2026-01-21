import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

/// Master passworddan 256-bit AES key hosil qiladi
Key deriveKeyFromPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes); // 32 bytes
  return Key(Uint8List.fromList(digest.bytes));
}

/// Plain textni AES bilan shifrlaydi
String encryptData(String plainText, Key key) {
  final iv = IV.fromLength(16); // 16 bytes IV (offline uchun OK)
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

/// AES bilan shifrdan chiqaradi
String decryptData(String encryptedText, Key key) {
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
  return decrypted;
}
