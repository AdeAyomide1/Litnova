import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_settings_provider.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/signup_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/explore/explore_screen.dart';
import '../../presentation/library/library_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/search/search_screen.dart';
import '../../presentation/book/book_detail_screen.dart';
import '../../presentation/notifications/notifications_screen.dart';
import '../../presentation/writer/writer_application_screen.dart';
import '../../presentation/writer/writer_dashboard_screen.dart';
import '../../presentation/writer/upload_book_screen.dart';
import '../../presentation/writer/add_chapter_screen.dart';
import '../../presentation/writer/manage_books_screen.dart';
import '../../presentation/reader/novel_reader_screen.dart';
import '../../presentation/reader/comic_reader_screen.dart';
import '../../presentation/reader/audio_player_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/settings/home_customization_screen.dart';
import '../../presentation/settings/theme_customization_screen.dart';
import '../../presentation/settings/about_screen.dart';
import '../../presentation/settings/privacy_policy_screen.dart';
import '../../presentation/settings/change_password_screen.dart';
import '../../presentation/sources/sources_screen.dart';
import '../../presentation/sources/source_browse_screen.dart';
import '../../presentation/sources/source_reader_screen.dart';
import '../../data/models/source_model.dart';
import '../../data/services/auth_service.dart';
import '../../presentation/profile/edit_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isLoggedIn = await AuthService.isLoggedIn();
      final location = state.matchedLocation;
      final publicRoutes = [
        '/splash', '/onboarding', '/login', '/signup',
      ];
      final isPublic = publicRoutes.contains(location);
      if (!isLoggedIn && !isPublic) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/book/:id',
        builder: (_, state) => BookDetailScreen(
          bookId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/home',
        builder: (_, __) => const HomeCustomizationScreen(),
      ),
      GoRoute(
        path: '/settings/theme',
        builder: (_, __) => const ThemeCustomizationScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (_, __) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/settings/password',
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/sources',
        builder: (_, __) => const SourcesScreen(),
      ),
      GoRoute(
        path: '/sources/browse/:sourceId',
        builder: (_, state) => SourceBrowseScreen(
          sourceId: state.pathParameters['sourceId']!,
        ),
      ),
      GoRoute(
        path: '/sources/reader/:sourceId/:bookId',
        builder: (_, state) => SourceReaderScreen(
          sourceId: state.pathParameters['sourceId']!,
          bookId: state.pathParameters['bookId']!,
          book: state.extra as SourceBook?,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (_, __) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (_, __) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/read/novel/:id',
        builder: (_, state) => NovelReaderScreen(
          bookId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/read/comic/:id',
        builder: (_, state) => ComicReaderScreen(
          bookId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/read/audio/:id',
        builder: (_, state) => AudioPlayerScreen(
          bookId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _tabs = ['/home', '/explore', '/library', '/profile'];

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsProvider();
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: settings.bgColor,
          body: widget.child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: settings.bgColor,
            selectedItemColor: settings.currentAccentColor,
            unselectedItemColor: settings.textFaintColor,
            selectedLabelStyle: const TextStyle(fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 0,
            onTap: (i) {
              setState(() => _currentIndex = i);
              context.go(_tabs[i]);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_rounded),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
