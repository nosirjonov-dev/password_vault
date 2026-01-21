import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'password_entry.g.dart';

@HiveType(typeId: 0)
class PasswordEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String encryptedPassword;

  @HiveField(3)
  final DateTime createdAt;

  PasswordEntry({
    String? id,
    required this.title,
    required this.encryptedPassword,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Faqat xotirada ishlatiladi (Hive'ga yozilmaydi!)
  String? plainPassword;
}
