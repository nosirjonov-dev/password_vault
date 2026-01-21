import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock Vault'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your master password to unlock the vault.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Master Password',
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const SizedBox(height: 24),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _onUnlock,
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onUnlock() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final password = _passwordController.text.trim();
    final success =
    await ref.read(authProvider.notifier).unlock(password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      setState(() => _error = 'Incorrect password');
      return;
    }

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
