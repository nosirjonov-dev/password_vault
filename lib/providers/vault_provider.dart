import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/password_entry.dart';
import '../repositories/vault_repository.dart';
import 'auth_provider.dart';

final vaultRepositoryProvider =
Provider<VaultRepository>((ref) => VaultRepository());

final entriesProvider = FutureProvider<List<PasswordEntry>>((ref) async {
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated || authState.masterKey == null) {
    throw Exception('Not authenticated');
  }

  final repo = ref.read(vaultRepositoryProvider);
  return repo.getEntries(authState.masterKey!);
});
