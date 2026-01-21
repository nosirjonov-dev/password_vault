import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  /// Master password hash saqlash
  Future<void> saveMasterPasswordHash(String hash) async {
    await _storage.write(key: 'master_hash', value: hash);
  }

  /// Master password hash olish
  Future<String?> getMasterPasswordHash() async {
    return await _storage.read(key: 'master_hash');
  }

  /// Hammasini tozalash (test yoki reset uchun)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
