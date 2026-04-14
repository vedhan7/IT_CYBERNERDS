import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data model for an event.
class Event {
  final String id;
  final String title;
  final String description;
  final String clubId;
  final String clubName;
  final String venue;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final DateTime registrationDeadline;
  final int maxParticipants;
  final int registeredCount;
  final String? bannerUrl;
  final String tag;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.clubId,
    required this.clubName,
    required this.venue,
    required this.startDateTime,
    required this.endDateTime,
    required this.registrationDeadline,
    required this.maxParticipants,
    this.registeredCount = 0,
    this.bannerUrl,
    this.tag = 'General',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get availableSlots => maxParticipants - registeredCount;
  bool get isFull => availableSlots <= 0;
  bool get isDeadlinePassed => DateTime.now().isAfter(registrationDeadline);

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      clubId: json['club_id'] as String? ?? 'default',
      clubName: json['club_name'] as String? ?? 'Cyber Nauts',
      venue: json['venue'] as String,
      startDateTime: DateTime.parse(json['start_date_time'] as String),
      endDateTime: DateTime.parse(json['end_date_time'] as String),
      registrationDeadline: DateTime.parse(json['registration_deadline'] as String),
      maxParticipants: json['max_participants'] as int,
      bannerUrl: json['banner_url'] as String?,
      tag: json['tag'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      registeredCount: json['registered_count'] ?? 0,
    );
  }
}

/// Repository for event CRUD operations using Supabase.
class EventRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD BANNER — Supabase Storage (replaces base64)
  // ══════════════════════════════════════════════════════════════════════════
  /// Uploads an image to the 'event-images' Supabase Storage bucket.
  /// Returns the public URL of the uploaded image.
  Future<String> uploadBanner(String eventId, File file) async {
    // Generate unique filename using timestamp to prevent overwrites
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = file.path.split('.').last;
    final filePath = 'banners/${eventId}_$timestamp.$ext';

    debugPrint('📤 Uploading banner: $filePath');

    try {
      await _client.storage.from('event-images').upload(
        filePath,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      // Get the public URL
      final publicUrl = _client.storage
          .from('event-images')
          .getPublicUrl(filePath);

      debugPrint('✅ Banner uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Banner upload failed: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CREATE EVENT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> createEvent(Event event) async {
    await _client.from('events').insert({
      'title': event.title,
      'description': event.description,
      'club_id': event.clubId == 'default' ? null : event.clubId,
      'club_name': event.clubName,
      'venue': event.venue,
      'start_date_time': event.startDateTime.toIso8601String(),
      'end_date_time': event.endDateTime.toIso8601String(),
      'registration_deadline': event.registrationDeadline.toIso8601String(),
      'max_participants': event.maxParticipants,
      'banner_url': event.bannerUrl,
      'tag': event.tag,
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE EVENT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    final Map<String, dynamic> updates = {};

    final mapToDb = {
      'title': 'title',
      'description': 'description',
      'clubId': 'club_id',
      'clubName': 'club_name',
      'venue': 'venue',
      'startDateTime': 'start_date_time',
      'endDateTime': 'end_date_time',
      'registrationDeadline': 'registration_deadline',
      'maxParticipants': 'max_participants',
      'bannerUrl': 'banner_url',
      'tag': 'tag',
    };

    data.forEach((key, value) {
      if (mapToDb.containsKey(key)) {
        final dbKey = mapToDb[key]!;
        if (value is DateTime) {
          updates[dbKey] = value.toIso8601String();
        } else {
          updates[dbKey] = value;
        }
      }
    });

    if (updates.isEmpty) return;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await _client.from('events').update(updates).eq('id', eventId);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE EVENT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> deleteEvent(String eventId) async {
    await _client.from('events').delete().eq('id', eventId);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET EVENTS
  // ══════════════════════════════════════════════════════════════════════════
  Future<List<Event>> getEvents() async {
    final data = await _client
        .from('events')
        .select()
        .order('start_date_time', ascending: true);

    final events = <Event>[];
    for (final row in data as List) {
      final countResult = await _client
          .from('registrations')
          .select()
          .eq('event_id', row['id']);
      row['registered_count'] = (countResult as List).length;
      events.add(Event.fromJson(row));
    }
    return events;
  }

  Future<List<Event>> getEventsByClub(String clubId) async {
    final data = await _client
        .from('events')
        .select()
        .eq('club_id', clubId)
        .order('start_date_time', ascending: true);

    final events = <Event>[];
    for (final row in data as List) {
      final countResult = await _client
          .from('registrations')
          .select()
          .eq('event_id', row['id']);
      row['registered_count'] = (countResult as List).length;
      events.add(Event.fromJson(row));
    }
    return events;
  }

  Future<Event> getEvent(String eventId) async {
    final row = await _client
        .from('events')
        .select()
        .eq('id', eventId)
        .single();

    final countResult = await _client
        .from('registrations')
        .select()
        .eq('event_id', eventId);
    row['registered_count'] = (countResult as List).length;

    return Event.fromJson(row);
  }
}
