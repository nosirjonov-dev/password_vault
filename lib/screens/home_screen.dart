import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/vault_provider.dart';
import 'add_password_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              authNotifier.lock();
              Navigator.pushReplacementNamed(context, '/lock');
            },
          ),
        ],
      ),
      body: entriesAsync.when(
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('No passwords yet. Add one!'))
            : ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              title: Text(entry.title),
              subtitle: Text(
                entry.plainPassword != null
                    ? '•••••• (${entry.plainPassword!.length} chars)'
                    : 'Error',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  if (entry.plainPassword == null) return;

                  await Clipboard.setData(
                    ClipboardData(text: entry.plainPassword!),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password copied')),
                  );
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPasswordScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
