import 'package:supabase_flutter/supabase_flutter.dart';
import '../../admin/data/event_repository.dart';

/// Repository for event registration (join / leave).
class RegistrationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Join an event
  Future<void> joinEvent(String eventId, String userId) async {
    await _client.from('registrations').insert({
      'event_id': eventId,
      'user_id': userId,
    });
  }

  /// Leave an event
  Future<void> leaveEvent(String eventId, String userId) async {
    await _client
        .from('registrations')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  /// Fetch events the user has registered for.
  Future<List<Event>> getUserRegistrations(String userId) async {
    // Get registration records for this user
    final regData = await _client
        .from('registrations')
        .select('event_id')
        .eq('user_id', userId);

    if ((regData as List).isEmpty) return [];

    final eventIds = regData.map((r) => r['event_id'] as String).toList();

    // Fetch those events
    final eventsData = await _client
        .from('events')
        .select()
        .inFilter('id', eventIds)
        .order('start_date_time', ascending: true);

    final events = <Event>[];
    for (final row in eventsData as List) {
      final countResult = await _client
          .from('registrations')
          .select()
          .eq('event_id', row['id']);
      row['registered_count'] = (countResult as List).length;
      events.add(Event.fromJson(row));
    }
    return events;
  }
}
