import 'package:flutter/material.dart';
import 'models/models.dart';

// Holds the logic for the edit profile dialog
class EditProfileDialog extends StatefulWidget {
  final AppUser user;

  const EditProfileDialog({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _profileImageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _profileImageUrlController =
        TextEditingController(text: widget.user.profileImageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  // Handles form submission
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = AppUser(
      id: widget.user.id,
      name: _nameController.text.trim(),
      email: widget.user.email,
      profileImageUrl: _profileImageUrlController.text.trim().isEmpty
        ? null
        : _profileImageUrlController.text.trim(),
      bio: _bioController.text.trim().isEmpty
        ? null
        : _bioController.text.trim(),
      followedOrganizationIds: widget.user.followedOrganizationIds,
      savedEventIds: widget.user.savedEventIds,
      memberOrganizationIds: widget.user.memberOrganizationIds,
      createdAt: widget.user.createdAt,
      updatedAt: DateTime.now(),
      role: widget.user.role,
    );

    Navigator.of(context).pop(updatedUser);
  }

  @override
  // Builds edit profile dialog
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Please enter a name.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _profileImageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Profile Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email and account metadata are read-only for now.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}