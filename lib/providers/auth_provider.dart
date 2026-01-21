import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';

import '../services/secure_storage_service.dart';
import '../utils/encryption.dart';

/// ====== STATE ======

class AuthState {
  final bool isAuthenticated;
  final Key? masterKey;

  const AuthState({
    required this.isAuthenticated,
    this.masterKey,
  });

  factory AuthState.unauthenticated() {
    return const AuthState(
      isAuthenticated: false,
      masterKey: null,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    Key? masterKey,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      masterKey: masterKey ?? this.masterKey,
    );
  }
}

/// ====== NOTIFIER ======

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _storage;

  AuthNotifier(this._storage) : super(AuthState.unauthenticated());

  /// Master passwordni tekshiradi va unlock qiladi
  Future<bool> unlock(String inputPassword) async {
    final storedHash = await _storage.getMasterPasswordHash();
    if (storedHash == null) return false;

    final inputHash = _hashPassword(inputPassword);

    if (inputHash != storedHash) {
      return false;
    }

    final key = deriveKeyFromPassword(inputPassword);

    state = state.copyWith(
      isAuthenticated: true,
      masterKey: key,
    );

    return true;
  }

  /// Birinchi marta master password o‘rnatish
  Future<void> setupMasterPassword(String password) async {
    final hash = _hashPassword(password);
    await _storage.saveMasterPasswordHash(hash);

    final key = deriveKeyFromPassword(password);

    state = state.copyWith(
      isAuthenticated: true,
      masterKey: key,
    );
  }

  /// Lock qilish (logout)
  void lock() {
    state = AuthState.unauthenticated();
  }

  /// SHA-256 bilan hash yaratish
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// ====== PROVIDERS ======

// SecureStorage singleton provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// Auth provider
final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.read(secureStorageProvider);
  return AuthNotifier(storage);
});
