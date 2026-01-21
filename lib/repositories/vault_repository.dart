import 'package:encrypt/encrypt.dart';
import 'package:hive/hive.dart';

import '../models/password_entry.dart';
import '../utils/encryption.dart';

class VaultRepository {
  static const String boxName = 'vault';

  Future<Box<PasswordEntry>> _openBox() async {
    return Hive.openBox<PasswordEntry>(boxName);
  }

  /// Encrypt qilib saqlaydi
  Future<void> saveEntry(PasswordEntry entry, Key masterKey) async {
    if (entry.plainPassword == null || entry.plainPassword!.isEmpty) {
      throw Exception('No password provided');
    }

    final encrypted = encryptData(entry.plainPassword!, masterKey);

    final newEntry = PasswordEntry(
      id: entry.id,
      title: entry.title,
      encryptedPassword: encrypted,
      createdAt: entry.createdAt,
    );

    final box = await _openBox();
    await box.put(newEntry.id, newEntry);
  }

  /// Decrypt qilib qaytaradi (faqat xotirada)
  Future<List<PasswordEntry>> getEntries(Key masterKey) async {
    final box = await _openBox();
    final entries = box.values.toList();

    return entries.map((e) {
      try {
        final plain = decryptData(e.encryptedPassword, masterKey);
        return PasswordEntry(
          id: e.id,
          title: e.title,
          encryptedPassword: e.encryptedPassword,
          createdAt: e.createdAt,
        )..plainPassword = plain;
      } catch (_) {
        return PasswordEntry(
          id: e.id,
          title: e.title,
          encryptedPassword: e.encryptedPassword,
          createdAt: e.createdAt,
        )..plainPassword = '[Decryption failed]';
      }
    }).toList();
  }

  Future<void> deleteEntry(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
