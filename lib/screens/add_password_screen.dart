import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/password_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/vault_provider.dart';

class AddPasswordScreen extends ConsumerStatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  ConsumerState<AddPasswordScreen> createState() =>
      _AddPasswordScreenState();
}

class _AddPasswordScreenState
    extends ConsumerState<AddPasswordScreen> {
  final _titleController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration:
              const InputDecoration(labelText: 'Title (e.g. Gmail)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final pw = _passwordController.text.trim();

                if (title.isEmpty || pw.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Fill in both fields')),
                  );
                  return;
                }

                final masterKey =
                    ref.read(authProvider).masterKey;
                if (masterKey == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Not authenticated')),
                  );
                  return;
                }

                final entry = PasswordEntry(
                  title: title,
                  encryptedPassword: '',
                )..plainPassword = pw;

                try {
                  final repo =
                  ref.read(vaultRepositoryProvider);
                  await repo.saveEntry(entry, masterKey);

                  ref.invalidate(entriesProvider);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password saved securely')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
