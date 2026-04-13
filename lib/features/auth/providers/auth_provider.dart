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

/// Hardcoded user state for bypasses
class HardcodedUserNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;
  void setUser(AppUser? user) => state = user;
}

final hardcodedUserProvider = NotifierProvider<HardcodedUserNotifier, AppUser?>(HardcodedUserNotifier.new);

/// Fetches the current user's Firestore profile.
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final hardcoded = ref.watch(hardcodedUserProvider);
  if (hardcoded != null) return hardcoded;

  try {
    return await ref.read(authRepositoryProvider).getCurrentUserData();
  } catch (_) {
    return null;
  }
});

/// Derived provider returning the user's role ("admin" or "student").
final userRoleProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.role);
});
