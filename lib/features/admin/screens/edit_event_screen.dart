import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/event_repository.dart';
import '../providers/admin_providers.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EditEventScreen({super.key, required this.eventId});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
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
  String? _existingBannerUrl;
  bool _isLoading = false;
  bool _isInitialized = false;

  final _tags = ['Tech', 'Cultural', 'Sports', 'Workshop', 'General'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  void _initFromEvent(Event event) {
    if (_isInitialized) return;
    _isInitialized = true;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _venueController.text = event.venue;
    _maxParticipantsController.text = event.maxParticipants.toString();
    _startDateTime = event.startDateTime;
    _endDateTime = event.endDateTime;
    _deadline = event.registrationDeadline;
    _selectedTag = event.tag;
    _existingBannerUrl = event.bannerUrl;
  }

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _bannerImage = File(picked.path));
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
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
    setState(() => _isLoading = true);
    try {
      String? bannerUrl = _existingBannerUrl;
      if (_bannerImage != null) {
        bannerUrl = await ref
            .read(eventRepositoryProvider)
            .uploadBanner(widget.eventId, _bannerImage!);
      }

      await ref.read(eventRepositoryProvider).updateEvent(widget.eventId, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'venue': _venueController.text.trim(),
        'startDateTime': _startDateTime,
        'endDateTime': _endDateTime,
        'registrationDeadline': _deadline,
        'maxParticipants': int.parse(_maxParticipantsController.text.trim()),
        'bannerUrl': bannerUrl,
        'tag': _selectedTag,
      });
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDt(DateTime? dt) {
    if (dt == null) return 'Select';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Event>(
      future: ref.read(eventRepositoryProvider).getEvent(widget.eventId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        _initFromEvent(snapshot.data!);

        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.editEvent)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            image: _bannerImage != null
                                ? DecorationImage(
                                    image: FileImage(_bannerImage!),
                                    fit: BoxFit.cover)
                                : _existingBannerUrl != null
                                    ? DecorationImage(
                                        image:
                                            NetworkImage(_existingBannerUrl!),
                                        fit: BoxFit.cover)
                                    : null,
                          ),
                          child: _bannerImage == null &&
                                  _existingBannerUrl == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                        size: 40),
                                    SizedBox(height: 8),
                                    Text('Change/Add Banner'),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      if (_bannerImage != null || _existingBannerUrl != null)
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
                                _existingBannerUrl = null;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => Validators.required(v, 'Title'),
                    decoration:
                        const InputDecoration(labelText: 'Event Title'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (v) =>
                        Validators.required(v, 'Description'),
                    decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _venueController,
                    validator: (v) => Validators.required(v, 'Venue'),
                    decoration: const InputDecoration(
                      labelText: 'Venue',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _datePickerTile('Start Date & Time', _startDateTime,
                      () => _pickDateTime('start')),
                  _datePickerTile('End Date & Time', _endDateTime,
                      () => _pickDateTime('end')),
                  _datePickerTile('Registration Deadline', _deadline,
                      () => _pickDateTime('deadline')),
                  TextFormField(
                    controller: _maxParticipantsController,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        Validators.required(v, 'Max Participants'),
                    decoration: const InputDecoration(
                      labelText: 'Max Participants',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Tag',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _tags.map((tag) {
                      return ChoiceChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        onSelected: (_) =>
                            setState(() => _selectedTag = tag),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    label: AppStrings.save,
                    isLoading: _isLoading,
                    useGradient: true,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        title:
            Text(label, style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(_formatDt(dt)),
        onTap: onTap,
      ),
    );
  }
}
