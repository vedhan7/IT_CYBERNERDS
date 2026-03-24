import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

/// Singleton auth repository provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Stream of Firebase Auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Fetches the current user's Firestore profile.
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  // Prototype Bypass: Return a mock user instead of requiring Firebase Auth.
  return AppUser(
    uid: 'mock_uid_123',
    name: 'Jane Student',
    email: 'jane@college.edu',
    college: 'Default College',
    department: 'Computer Science',
    role: 'student',
    createdAt: DateTime.now(),
    joinedEvents: ['e1'],
  );
});

/// Derived provider returning the user's role ("admin" or "student").
final userRoleProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.role);
});
