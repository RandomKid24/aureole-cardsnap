import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared/theme/app_theme.dart';
import 'core/auth/auth_service.dart';
import 'core/notifications/notification_service.dart';
import 'features/auth/login_screen.dart';
import 'features/contacts/list_screen.dart';
import 'features/contacts/detail_screen.dart';
import 'features/scan/camera_screen.dart';
import 'features/review/review_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/reminders/reminders_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class CardSnapApp extends StatefulWidget {
  final bool seenOnboarding;
  final AuthService auth;

  const CardSnapApp({super.key, required this.seenOnboarding, required this.auth});

  @override
  State<CardSnapApp> createState() => _CardSnapAppState();
}

class _CardSnapAppState extends State<CardSnapApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();

    // Open the contact when a reminder notification is tapped (foreground,
    // background, or cold start).
    NotificationService.onReminderTapped = (contactId) {
      _router.go('/contact/$contactId');
    };
    NotificationService.consumeLaunchPayload().then((contactId) {
      if (contactId != null) _router.go('/contact/$contactId');
    });
  }

  @override
  void dispose() {
    NotificationService.onReminderTapped = null;
    super.dispose();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: widget.auth,
      redirect: (context, state) {
        final auth = widget.auth;
        final loc = state.matchedLocation;

        // Still checking the stored token.
        if (auth.status == AuthStatus.unknown) {
          return loc == '/splash' ? null : '/splash';
        }

        final loggedIn = auth.isAuthenticated;
        if (!loggedIn) {
          return loc == '/login' ? null : '/login';
        }

        // Logged in — bounce away from the gate screens.
        if (loc == '/login' || loc == '/splash') {
          return widget.seenOnboarding ? '/' : '/onboarding';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => const _SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const ListScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/stats',
                  builder: (context, state) => const StatsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/scan',
          builder: (context, state) => const CameraScreen(),
        ),
        GoRoute(
          path: '/reminders',
          builder: (context, state) => const RemindersScreen(),
        ),
        GoRoute(
          path: '/review/:draftId',
          builder: (context, state) {
            return ReviewScreen(draftId: state.pathParameters['draftId']!);
          },
        ),
        GoRoute(
          path: '/contact/:id',
          builder: (context, state) {
            return DetailScreen(id: state.pathParameters['id']!);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CardSnap',
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.slateBg,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ScaffoldWithBottomNavBar extends StatelessWidget {
  const ScaffoldWithBottomNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.borderDivider, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index),
          backgroundColor: AppTheme.white,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.stone,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts_outlined),
              activeIcon: Icon(Icons.contacts),
              label: 'CONTACTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'STATS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}
