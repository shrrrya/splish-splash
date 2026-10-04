import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../providers/saved_provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Temporary placeholders; we replace these one by one.
    final List<Widget> _tabs = const [
    HomeScreen(),
    _Placeholder('Search'),
    _SavedTest(),
    _ProfileTest(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (int i = 0; i < _tabs.length; i++)
            AnimatedOpacity(
              opacity: i == _index ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: _tabs[i],
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Saved'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('$title (coming soon)'));
}

// ---- Temporary test screens, to prove the saved provider works ----

final _testPhoto = Photo(
  id: 1,
  photographer: 'Test',
  width: 100,
  height: 100,
  thumbUrl: '',
  largeUrl: '',
  pageUrl: '',
);

class _SavedTest extends StatelessWidget {
  const _SavedTest();

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Saved count: ${saved.count}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.read<SavedProvider>().toggle(_testPhoto),
            child: Text(saved.isSaved(1) ? 'Remove test photo' : 'Save test photo'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTest extends StatelessWidget {
  const _ProfileTest();

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUser?.email ?? '';
    final count = context.watch<SavedProvider>().count;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(email),
          const SizedBox(height: 8),
          Text('Saved items: $count'),
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
    );
  }
}