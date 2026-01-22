import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/password_entry.dart';
import 'screens/onboarding_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart'; // 👈 MUHIM

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PasswordEntryAdapter());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Vault',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const VaultInitializer(),
      routes: {
        '/onboarding': (_) => OnboardingScreen(),
        '/lock': (_) => LockScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

class VaultInitializer extends ConsumerStatefulWidget {
  const VaultInitializer({super.key});

  @override
  ConsumerState<VaultInitializer> createState() => _VaultInitializerState();
}

class _VaultInitializerState extends ConsumerState<VaultInitializer> {
  ProviderListenable? get secureStorageProvider => null;

  @override
  void initState() {
    super.initState();
    _checkVaultSetup();
  }

  Future<void> _checkVaultSetup() async {
    final storage = ref.read(secureStorageProvider!);
    final isSetup = await storage.isVaultSetup();

    if (!mounted) return;

    if (!isSetup) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/lock');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
