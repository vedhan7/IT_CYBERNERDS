import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String email;
  final String college;
  final String department;
  final String role;
  final DateTime createdAt;
  final int joinedEventsCount;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.college,
    required this.department,
    required this.role,
    required this.createdAt,
    this.joinedEventsCount = 0,
  });

  /// Parse from Supabase query result (Map<String, dynamic>).
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      college: (json['college'] ?? '') as String,
      department: (json['department'] ?? '') as String,
      role: (json['role'] ?? 'student') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      joinedEventsCount: json['join_count'] != null
          ? int.parse(json['join_count'].toString())
          : 0,
    );
  }

  bool get isAdmin => role == 'admin';
}

/// Structured API error for clean error propagation.
class ApiError implements Exception {
  final int statusCode;
  final String message;
  final String? field;

  ApiError({required this.statusCode, required this.message, this.field});

  @override
  String toString() => message;
}

// ─── Repository ──────────────────────────────────────────────────────────────

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN UP
  // ══════════════════════════════════════════════════════════════════════════
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required String college,
    required String department,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final cleanCollege = college.trim();
    final cleanDept = department.trim();

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📤 REGISTRATION — PRE-FLIGHT');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('Email    : "$cleanEmail"');
    debugPrint('Name     : "$cleanName"');
    debugPrint('College  : "$cleanCollege"');
    debugPrint('Dept     : "$cleanDept"');
    debugPrint('Password : ${password.length} chars');

    // Determine role
    final isRequestingAdmin = cleanEmail.contains('admin');
    final role = isRequestingAdmin ? 'admin' : 'student';

    // Pre-flight: check admin constraint
    if (isRequestingAdmin) {
      final existing = await _client
          .from('users')
          .select('id')
          .eq('role', 'admin');
      if ((existing as List).isNotEmpty) {
        throw ApiError(statusCode: 409, message: 'An admin account already exists');
      }
    }

    // ── Step 1: Sign up with Supabase Auth ──
    try {
      final AuthResponse authResponse = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'name': cleanName}, // stored in auth.users.raw_user_meta_data
      );

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📥 SUPABASE AUTH RESPONSE');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('User ID  : ${authResponse.user?.id}');
      debugPrint('Email    : ${authResponse.user?.email}');
      debugPrint('Session  : ${authResponse.session != null ? 'present' : 'null'}');

      final user = authResponse.user;
      if (user == null) {
        throw ApiError(
          statusCode: 500,
          message: 'Sign-up succeeded but no user returned. Check email confirmation settings.',
        );
      }

      // ── Step 2: Insert into public.users table ──
      debugPrint('📝 Inserting into public.users...');
      try {
        await _client.from('users').insert({
          'id': user.id,
          'name': cleanName,
          'email': cleanEmail,
          'college': cleanCollege,
          'department': cleanDept,
          'role': role,
        });
      } catch (e) {
        debugPrint('❌ public.users insert failed: $e');
        // Classify Postgres errors
        final msg = e.toString();
        if (msg.contains('duplicate key') || msg.contains('unique') || msg.contains('23505')) {
          if (msg.contains('email')) {
            throw ApiError(statusCode: 409, message: 'An account with this email already exists', field: 'email');
          }
          if (msg.contains('name')) {
            throw ApiError(statusCode: 409, message: 'This username is already taken', field: 'name');
          }
          throw ApiError(statusCode: 409, message: 'Account already exists');
        }
        throw ApiError(statusCode: 500, message: 'Failed to create user profile: $e');
      }

      // ── Step 3: Fetch the complete user profile ──
      final profile = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      final appUser = AppUser.fromJson(profile);

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✅ REGISTRATION COMPLETE');
      debugPrint('  ID   : ${appUser.id}');
      debugPrint('  Email: ${appUser.email}');
      debugPrint('  Role : ${appUser.role}');
      debugPrint('═══════════════════════════════════════════════════════════');

      return appUser;

    } on AuthException catch (e) {
      debugPrint('❌ AUTH EXCEPTION: ${e.message} (code: ${e.statusCode})');
      throw ApiError(
        statusCode: int.tryParse(e.statusCode ?? '') ?? 400,
        message: e.message,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN IN
  // ══════════════════════════════════════════════════════════════════════════
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📤 SIGN-IN — PRE-FLIGHT');
    debugPrint('Email: "$cleanEmail"');
    debugPrint('═══════════════════════════════════════════════════════════');

    try {
      final AuthResponse authResponse = await _client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      debugPrint('✅ Auth sign-in OK. User ID: ${authResponse.user?.id}');

      final user = authResponse.user;
      if (user == null) {
        throw ApiError(statusCode: 401, message: 'Invalid credentials');
      }

      // Fetch profile from public.users
      final results = await _client
          .from('users')
          .select()
          .eq('id', user.id);

      if ((results as List).isEmpty) {
        throw ApiError(
          statusCode: 404,
          message: 'Your identity was verified but your profile is missing. Please contact support.',
        );
      }

      final Map<String, dynamic> userMap = Map<String, dynamic>.from(results[0]);
      try {
        final countResult = await _client
            .from('registrations')
            .select('id')
            .eq('user_id', user.id);
        userMap['join_count'] = (countResult as List).length;
      } catch (_) {
        userMap['join_count'] = 0;
      }

      final appUser = AppUser.fromJson(userMap);
      debugPrint('✅ SIGN-IN COMPLETE: ${appUser.email} (${appUser.role})');
      return appUser;

    } on AuthException catch (e) {
      debugPrint('❌ AUTH EXCEPTION: ${e.message}');
      throw ApiError(
        statusCode: int.tryParse(e.statusCode ?? '') ?? 401,
        message: e.message,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> signOut() async {
    await _client.auth.signOut();
    debugPrint('✅ Signed out');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET CURRENT USER
  // ══════════════════════════════════════════════════════════════════════════
  Future<AppUser?> getCurrentUserData() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final results = await _client
          .from('users')
          .select()
          .eq('id', authUser.id);

      if ((results as List).isEmpty) return null;
      
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(results[0]);
      try {
        final countResult = await _client
            .from('registrations')
            .select('id')
            .eq('user_id', authUser.id);
        userMap['join_count'] = (countResult as List).length;
      } catch (_) {
        userMap['join_count'] = 0;
      }
      
      return AppUser.fromJson(userMap);
    } catch (e) {
      debugPrint('⚠️ Failed to fetch user profile: $e');
      return null;
    }
  }
}
