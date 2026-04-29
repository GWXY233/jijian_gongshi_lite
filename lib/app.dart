import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

final _shellKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = location.startsWith('/stats') ? 1 : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/stats');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
        ],
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '极简工时 Lite',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF5F6FF),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF12131A),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
