import '../features/admin/data/club_repository.dart';
import '../features/admin/data/event_repository.dart';

final mockClubs = [
  Club(id: 'c1', name: 'CyberNerds', description: 'Tech Club focused on web apps and security.', createdAt: DateTime.now()),
  Club(id: 'c2', name: 'Artistry', description: 'Cultural Club for arts and dance.', createdAt: DateTime.now()),
  Club(id: 'c3', name: 'SportsHub', description: 'Sports Club promoting fitness.', createdAt: DateTime.now()),
];

final mockEvents = [
  Event(
    id: 'e1',
    title: 'Hackathon 2026',
    description: 'Annual college hackathon bringing minds together.',
    clubId: 'c1',
    clubName: 'CyberNerds',
    venue: 'Main Auditorium',
    startDateTime: DateTime.now().add(const Duration(days: 2)),
    endDateTime: DateTime.now().add(const Duration(days: 3)),
    registrationDeadline: DateTime.now().add(const Duration(days: 1)),
    maxParticipants: 100,
    tag: 'Tech',
  ),
  Event(
    id: 'e2',
    title: 'Dance Off',
    description: 'Show your moves in the ultimate dance battle.',
    clubId: 'c2',
    clubName: 'Artistry',
    venue: 'Open Air Theatre',
    startDateTime: DateTime.now().add(const Duration(days: 5)),
    endDateTime: DateTime.now().add(const Duration(days: 5, hours: 4)),
    registrationDeadline: DateTime.now().add(const Duration(days: 4)),
    maxParticipants: 50,
    tag: 'Cultural',
  ),
  Event(
    id: 'e3',
    title: 'Inter-College Football',
    description: 'The big autumn football tournament.',
    clubId: 'c3',
    clubName: 'SportsHub',
    venue: 'College Ground',
    startDateTime: DateTime.now().add(const Duration(days: 10)),
    endDateTime: DateTime.now().add(const Duration(days: 12)),
    registrationDeadline: DateTime.now().add(const Duration(days: 8)),
    maxParticipants: 200,
    tag: 'Sports',
  )
];
