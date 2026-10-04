import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = AuthService().currentUser?.email ?? '';
    final count = context.select<SavedProvider, int>((s) => s.count);
    final themeProvider = context.watch<ThemeProvider>();
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              child: Text(initial, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(email, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Saved photos'),
              trailing: Text(
                '$count',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Theme', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light')),
              ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark')),
              ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest_outlined),
                  label: Text('System')),
            ],
            selected: {themeProvider.mode},
            onSelectionChanged: (s) => themeProvider.setMode(s.first),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            icon: Icon(Icons.logout, color: theme.colorScheme.error),
            label: Text('Logout',
                style: TextStyle(color: theme.colorScheme.error)),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('Photos from Pixabay',
                style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}