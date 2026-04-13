import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/admin/screens/admin_shell.dart';
import '../features/admin/screens/admin_events_screen.dart';
import '../features/admin/screens/create_event_screen.dart';
import '../features/admin/screens/edit_event_screen.dart';
import '../features/admin/screens/event_detail_admin_screen.dart';
import '../features/admin/screens/admin_clubs_screen.dart';
import '../features/admin/screens/create_club_screen.dart';
import '../features/admin/screens/club_detail_admin_screen.dart';
import '../features/admin/screens/admin_profile_screen.dart';
import '../features/user/screens/user_shell.dart';
import '../features/user/screens/home_screen.dart';
import '../features/user/screens/events_screen.dart';
import '../features/user/screens/event_detail_user_screen.dart';
import '../features/user/screens/my_events_screen.dart';
import '../features/user/screens/club_detail_user_screen.dart';
import '../features/user/screens/user_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminShellKey = GlobalKey<NavigatorState>();
final _userShellKey = GlobalKey<NavigatorState>();

/// Main app router provider.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userRole = ref.watch(userRoleProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider).value;
      final hardcodedUser = ref.watch(hardcodedUserProvider);
      final isLoggedIn = authState != null || hardcodedUser != null;
      
      final isSplash = state.matchedLocation == '/splash';
      final isLoginOrRegister = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (isSplash) {
        if (!isLoggedIn) return '/login';
        if (hardcodedUser != null) {
          return hardcodedUser.isAdmin ? '/admin' : '/user';
        }
        return userRole == 'admin' ? '/admin' : '/user';
      }

      if (isLoggedIn && isLoginOrRegister) {
        if (hardcodedUser != null) {
          return hardcodedUser.isAdmin ? '/admin' : '/user';
        }
        return userRole == 'admin' ? '/admin' : '/user';
      }

      if (!isLoggedIn && !isLoginOrRegister) {
        return '/login';
      }

      return null;
    },
    routes: [
      // ── Auth routes ──
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Admin shell ──
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _adminShellKey,
            routes: [
              GoRoute(
                path: '/admin',
                builder: (_, __) => const AdminEventsScreen(),
                routes: [
                  GoRoute(
                    path: 'create-event',
                    builder: (_, __) => const CreateEventScreen(),
                  ),
                  GoRoute(
                    path: 'event/:eventId',
                    builder: (_, state) => EventDetailAdminScreen(
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'edit-event/:eventId',
                    builder: (_, state) => EditEventScreen(
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/clubs',
                builder: (_, __) => const AdminClubsScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (_, __) => const CreateClubScreen(),
                  ),
                  GoRoute(
                    path: ':clubId',
                    builder: (_, state) => ClubDetailAdminScreen(
                      clubId: state.pathParameters['clubId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                builder: (_, __) => const AdminProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── User shell ──
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            UserShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _userShellKey,
            routes: [
              GoRoute(
                path: '/user',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user/events',
                builder: (_, __) => const EventsScreen(),
                routes: [
                  GoRoute(
                    path: ':eventId',
                    builder: (_, state) => EventDetailUserScreen(
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user/my-events',
                builder: (_, __) => const MyEventsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user/profile',
                builder: (_, __) => const UserProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Club detail (user side, outside shell for full-screen) ──
      GoRoute(
        path: '/user/club/:clubId',
        builder: (_, state) => ClubDetailUserScreen(
          clubId: state.pathParameters['clubId']!,
        ),
      ),
    ],
  );
});
