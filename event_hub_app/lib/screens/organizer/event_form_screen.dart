import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class EventFormScreen extends StatefulWidget {
  final EventModel? eventToEdit;

  const EventFormScreen({super.key, this.eventToEdit});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _priceController;
  late TextEditingController _seatsController;
  late TextEditingController _imageController;
  late TextEditingController _tagsController;

  String _selectedCategory = 'Technology';
  bool _isSaving = false;

  final List<String> _categories = [
    'Technology',
    'Music',
    'Food & Drinks',
    'Sports',
    'Arts & Culture',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.eventToEdit;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _dateController = TextEditingController(text: e?.date ?? '2026-11-15');
    _timeController = TextEditingController(text: e?.time ?? '10:00 AM - 04:00 PM');
    _priceController = TextEditingController(text: e != null ? e.price.toString() : '49.00');
    _seatsController = TextEditingController(text: e != null ? e.totalSeats.toString() : '100');
    _imageController = TextEditingController(
      text: e?.image ??
          'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1200&q=80',
    );
    _tagsController = TextEditingController(text: e != null ? e.tags.join(', ') : 'Popular, Live');
    if (e != null && _categories.contains(e.category)) {
      _selectedCategory = e.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _imageController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final eventsProv = context.read<EventsProvider>();
    final user = auth.currentUser;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    bool success;
    if (widget.eventToEdit != null) {
      // Edit mode
      final updates = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'totalSeats': int.tryParse(_seatsController.text.trim()) ?? 50,
        'image': _imageController.text.trim(),
        'tags': tags,
      };
      success = await eventsProv.updateEvent(
        widget.eventToEdit!.id,
        updates,
        auth.token,
      );
    } else {
      // Create mode
      final newEvent = EventModel(
        id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        location: _locationController.text.trim(),
        date: _dateController.text.trim(),
        time: _timeController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        availableSeats: int.tryParse(_seatsController.text.trim()) ?? 50,
        totalSeats: int.tryParse(_seatsController.text.trim()) ?? 50,
        organizerId: user?.id ?? 'usr_org1',
        organizerName: user?.name ?? 'Event Organizer',
        image: _imageController.text.trim(),
        tags: tags,
      );
      success = await eventsProv.addEvent(newEvent, auth.token);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Add New Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'e.g. Annual Jazz Under The Stars',
                prefixIcon: Icons.title_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    dropdownColor: isDark ? AppTheme.surfaceDark : Colors.white,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.category_rounded, size: 20)),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descController,
                label: 'Event Description',
                hint: 'Provide a rich overview of the event, itinerary, and what to expect...',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _dateController,
                      label: 'Date',
                      hint: 'YYYY-MM-DD',
                      prefixIcon: Icons.calendar_today_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Date required' : null,
                    ),
                  ),
                  IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.edit_calendar_rounded, color: AppTheme.primary),
                    tooltip: 'Pick Date',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _timeController,
                label: 'Time Range',
                hint: '09:00 AM - 05:00 PM',
                prefixIcon: Icons.access_time_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Time is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _locationController,
                label: 'Location / Venue Address',
                hint: 'e.g. Royal Hall, 45 Central Ave, Chicago',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),

              // Price & Seats
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Price per ticket (\$)',
                      hint: '0.00',
                      prefixIcon: Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Price required';
                        if (double.tryParse(v.trim()) == null) return 'Enter number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: _seatsController,
                      label: 'Total Capacity',
                      hint: '100',
                      prefixIcon: Icons.event_seat_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Seats required';
                        if (int.tryParse(v.trim()) == null) return 'Enter integer';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _imageController,
                label: 'Cover Image URL',
                hint: 'https://...',
                prefixIcon: Icons.image_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Image URL required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _tagsController,
                label: 'Tags (comma separated)',
                hint: 'Music, Outdoor, Festival',
                prefixIcon: Icons.tag_rounded,
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveEvent,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Publish Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
