import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/event_repository.dart';
import '../data/club_repository.dart';
import '../../../core/mock_data.dart'; // MOCK DATA IMPORT

/// Singleton event repository provider.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

/// Stream of all events.
final eventsStreamProvider = StreamProvider<List<Event>>((ref) {
  return Stream.value(mockEvents);
});

/// Stream of events for a specific club.
final eventsByClubProvider =
    StreamProvider.family<List<Event>, String>((ref, clubId) {
  return Stream.value(mockEvents.where((e) => e.clubId == clubId).toList());
});

/// Singleton club repository provider.
final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepository();
});

/// Stream of all clubs.
final clubsStreamProvider = StreamProvider<List<Club>>((ref) {
  return Stream.value(mockClubs);
});
