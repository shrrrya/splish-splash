import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeProvider>().mode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SplishSplash',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: mode,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const _TempHome(),
      },
    );
  }
}

// Temporary screen for testing auth. We'll replace it with the real home.
class _TempHome extends StatelessWidget {
  const _TempHome();

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUser?.email ?? '';
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Signed in as $email'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}