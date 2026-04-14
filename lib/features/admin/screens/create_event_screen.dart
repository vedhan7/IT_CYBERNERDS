import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/event_repository.dart';
import '../providers/admin_providers.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  DateTime? _deadline;
  String _selectedTag = 'General';
  File? _bannerImage;
  bool _isLoading = false;
  bool _isUploading = false; // Separate state for upload progress

  final _tags = ['Tech', 'Cultural', 'Sports', 'Workshop', 'General'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 80, // Compress to reduce upload size
    );
    if (picked != null) {
      setState(() => _bannerImage = File(picked.path));
    }
  }

  Future<void> _pickDateTime(String field) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      switch (field) {
        case 'start':
          _startDateTime = dt;
          break;
        case 'end':
          _endDateTime = dt;
          break;
        case 'deadline':
          _deadline = dt;
          break;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDateTime == null || _endDateTime == null || _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set all date/times')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventId = const Uuid().v4();
      String? bannerUrl;

      // ── Upload banner to Supabase Storage ──
      if (_bannerImage != null) {
        setState(() => _isUploading = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 16),
                  Text('Uploading banner image...'),
                ],
              ),
              duration: Duration(seconds: 30),
            ),
          );
        }

        bannerUrl = await ref
            .read(eventRepositoryProvider)
            .uploadBanner(eventId, _bannerImage!);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          setState(() => _isUploading = false);
        }
      }

      // ── Create the event record ──
      final event = Event(
        id: eventId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        clubId: 'default',
        clubName: 'Cyber Nauts',
        venue: _venueController.text.trim(),
        startDateTime: _startDateTime!,
        endDateTime: _endDateTime!,
        registrationDeadline: _deadline!,
        maxParticipants: int.parse(_maxParticipantsController.text.trim()),
        bannerUrl: bannerUrl,
        tag: _selectedTag,
      );

      await ref.read(eventRepositoryProvider).createEvent(event);

      // Invalidate events cache so the list refreshes
      ref.invalidate(eventsStreamProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event created successfully! 🎉'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() {
        _isLoading = false;
        _isUploading = false;
      });
    }
  }

  String _formatDt(DateTime? dt) {
    if (dt == null) return 'Select';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createEvent)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Banner picker ──
              Stack(
                alignment: Alignment.topRight,
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        image: _bannerImage != null
                            ? DecorationImage(
                                image: FileImage(_bannerImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _bannerImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 40),
                                SizedBox(height: 8),
                                Text('Add Banner Image'),
                              ],
                            )
                          : _isUploading
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(color: Colors.white),
                                        SizedBox(height: 12),
                                        Text('Uploading...', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                )
                              : null,
                    ),
                  ),
                  if (_bannerImage != null && !_isUploading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close),
                        tooltip: 'Remove Banner',
                        onPressed: () {
                          setState(() {
                            _bannerImage = null;
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Title ──
              TextFormField(
                controller: _titleController,
                validator: (v) => Validators.required(v, 'Title'),
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              const SizedBox(height: 14),

              // ── Description ──
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) => Validators.required(v, 'Description'),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),

              // ── Venue ──
              TextFormField(
                controller: _venueController,
                validator: (v) => Validators.required(v, 'Venue'),
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // ── DateTime pickers ──
              _datePickerTile('Start Date & Time', _startDateTime, () => _pickDateTime('start')),
              _datePickerTile('End Date & Time', _endDateTime, () => _pickDateTime('end')),
              _datePickerTile('Registration Deadline', _deadline, () => _pickDateTime('deadline')),

              // ── Max Participants ──
              TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.required(v, 'Max Participants'),
                decoration: const InputDecoration(
                  labelText: 'Max Participants',
                  prefixIcon: Icon(Icons.people_outline),
                ),
              ),
              const SizedBox(height: 14),

              // ── Tag chips ──
              Text('Tag', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return ChoiceChip(
                    label: Text(tag),
                    selected: _selectedTag == tag,
                    onSelected: (_) => setState(() => _selectedTag = tag),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Save ──
              CustomButton(
                label: _isUploading ? 'Uploading...' : AppStrings.save,
                isLoading: _isLoading,
                useGradient: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePickerTile(String label, DateTime? dt, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade400),
        ),
        leading: const Icon(Icons.calendar_today_outlined),
        title: Text(label, style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(_formatDt(dt)),
        onTap: onTap,
      ),
    );
  }
}
