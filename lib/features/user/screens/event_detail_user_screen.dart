import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/data/event_repository.dart';
import '../../admin/providers/admin_providers.dart';
import '../providers/user_providers.dart';

class EventDetailUserScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailUserScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailUserScreen> createState() =>
      _EventDetailUserScreenState();
}

class _EventDetailUserScreenState
    extends ConsumerState<EventDetailUserScreen> {
  bool _isLoading = false;

  Future<void> _joinEvent(Event event, String userId) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(registrationRepositoryProvider)
          .joinEvent(event.id, userId);
          
      ref.invalidate(eventsStreamProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(userRegistrationsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined!')),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveEvent(Event event, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave Event?'),
        content: const Text('You will lose your registration.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(registrationRepositoryProvider)
          .leaveEvent(event.id, userId);
      ref.invalidate(eventsStreamProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(userRegistrationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Left event successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);

    final userId = userAsync.value?.id;
    final regsAsync = userId != null ? ref.watch(userRegistrationsProvider(userId)) : null;
    final isRegistered = regsAsync?.value?.any((e) => e.id == widget.eventId) ?? false;

    return FutureBuilder<Event>(
      future: ref.read(eventRepositoryProvider).getEvent(widget.eventId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final event = snapshot.data!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: event.bannerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: event.bannerUrl!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.event,
                              size: 64, color: AppColors.primary),
                        ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title + tag
                    Row(
                      children: [
                        Expanded(
                          child: Text(event.title,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(event.tag,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(event.clubName,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const Divider(height: 32),

                    _infoTile(Icons.location_on_outlined, 'Venue',
                        event.venue, theme),
                    _infoTile(Icons.calendar_today_outlined, 'Starts',
                        DateFormatter.full(event.startDateTime), theme),
                    _infoTile(Icons.calendar_today_outlined, 'Ends',
                        DateFormatter.full(event.endDateTime), theme),
                    _infoTile(Icons.timer_outlined, 'Deadline',
                        DateFormatter.full(event.registrationDeadline), theme),
                    _infoTile(Icons.people_outline, 'Slots',
                        '${event.availableSlots} / ${event.maxParticipants} available',
                        theme),

                    const Divider(height: 32),
                    Text('Description',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(event.description, style: theme.textTheme.bodyMedium),

                    const SizedBox(height: 32),

                    // ── Action buttons ──
                    if (event.isDeadlinePassed)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_clock, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Registration Closed',
                                style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    else if (isRegistered) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.success),
                            SizedBox(width: 8),
                            Text('Already Registered',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Leave Event',
                        isLoading: _isLoading,
                        onPressed: () => _leaveEvent(event, userId!),
                      ),
                    ] else if (event.isFull)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, color: AppColors.warning),
                            SizedBox(width: 8),
                            Text('Event Full',
                                style: TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    else
                      CustomButton(
                        label: 'Join Event',
                        isLoading: _isLoading,
                        useGradient: true,
                        icon: Icons.how_to_reg,
                        onPressed: userId != null
                            ? () => _joinEvent(event, userId)
                            : null,
                      ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(
      IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
