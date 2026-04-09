import 'package:flutter/material.dart';
import 'models/models.dart';

// Holds the logic for the event form dialog
class EventFormDialog extends StatefulWidget {
  final Event? initialEvent;

  const EventFormDialog({
    super.key,
    this.initialEvent,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _onlineUrlController;
  late final TextEditingController _thumbnailUrlController;

  late DateTime _startTime;
  late DateTime _endTime;
  late bool _isOnline;

  bool get _isEditing => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();

    final event = widget.initialEvent;
    final location = event?.location;

    _nameController = TextEditingController(text: event?.name ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    _locationNameController = TextEditingController(text: location?.name ?? '');
    _addressController = TextEditingController(text: location?.address ?? '');
    _cityController = TextEditingController(text: location?.city ?? '');
    _stateController = TextEditingController(text: location?.state ?? '');
    _zipCodeController = TextEditingController(text: location?.zipCode ?? '');
    _onlineUrlController = TextEditingController(text: location?.onlineUrl ?? '');
    _thumbnailUrlController = TextEditingController(text: event?.thumbnailUrl ?? '');

    _startTime = event?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    _endTime = event?.endTime ?? DateTime.now().add(const Duration(hours: 2));
    _isOnline = location?.isOnline ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _onlineUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  // Generates an event id for a new event
  String _generateEventId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Returns a new event based on the form data
  Event _buildEvent() {
    final existing = widget.initialEvent;

    return Event(
      id: existing?.id ?? _generateEventId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      location: EventLocation(
        name: _isOnline
            ? (_locationNameController.text.trim().isEmpty
              ? 'Online'
              : _locationNameController.text.trim())
            : _locationNameController.text.trim(),
        address: _isOnline ? null : _emptyToNull(_addressController.text),
        city: _isOnline ? null : _emptyToNull(_cityController.text),
        state: _isOnline ? null : _emptyToNull(_stateController.text),
        zipCode: _isOnline ? null : _emptyToNull(_zipCodeController.text),
        latitude: existing?.location.latitude,
        longitude: existing?.location.longitude,
        isOnline: _isOnline,
        onlineUrl: _isOnline ? _emptyToNull(_onlineUrlController.text) : null,
      ),
      startTime: _startTime,
      endTime: _endTime,
      organizationId: existing?.organizationId ?? '000',
      tagIds: existing?.tagIds ?? [],
      thumbnailUrl: _emptyToNull(_thumbnailUrlController.text),
      attendance: existing?.attendance,
      status: existing?.status ?? EventStatus.published,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdByUserId: existing?.createdByUserId ?? '000',
    );
  }

  // Helper function to trim empty strings
  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  // Start time picking handler
  Future<void> _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2026),
      lastDate: DateTime(2036),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (time == null) return;

    setState(() {
      _startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (_endTime.isBefore(_startTime)) {
        _endTime = _startTime.add(const Duration(hours: 1));
      }
    });
  }

  // End time picking handler
  Future<void> _pickEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime(2026),
      lastDate: DateTime(2036),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (time == null) return;

    setState(() {
      _endTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  // Builds event dialog form interface
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Event' : 'Create Event'),
      content: SizedBox(
        width: 500,
        height: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                  validator: (value) =>
                  value == null || value
                      .trim()
                      .isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                  value == null || value
                      .trim()
                      .isEmpty ? 'Enter a description' : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online Event'),
                  value: _isOnline,
                  onChanged: (value) {
                    setState(() {
                      _isOnline = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationNameController,
                  decoration: InputDecoration(
                    labelText: _isOnline ? 'Platform' : 'Location Name',
                  ),
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Enter a location name'
                      : null,
                ),
                const SizedBox(height: 12),
                if (_isOnline) ...[
                  TextFormField(
                    controller: _onlineUrlController,
                    decoration: const InputDecoration(labelText: 'Online URL'),
                  ),
                ] else ...[
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _zipCodeController,
                      decoration: const InputDecoration(labelText: 'Zip Code'),
                    ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _thumbnailUrlController,
                  decoration: const InputDecoration(labelText: 'Thumbnail URL'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start Time'),
                  subtitle: Text(_startTime.toString()),
                  trailing: const Icon(Icons.schedule),
                  onTap: _pickStartTime,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End Time'),
                  subtitle: Text(_endTime.toString()),
                  trailing: const Icon(Icons.schedule),
                  onTap: _pickEndTime,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _buildEvent());
            }
          },
          child: Text(_isEditing ? 'Save Changes' : 'Create Event'),
        ),
      ],
    );
  }
}