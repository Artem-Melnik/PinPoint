import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/models.dart';

class SavedView extends StatelessWidget {
  final List<Event> savedEvents;
  final Set<String> followedOrganizationIds;
  final void Function(Event event)? onEventSelected;
  final void Function(Event event)? onToggleSavedEvent;
  final void Function(String organizationId)? onToggleFollowedOrganization;

  const SavedView({
    super.key,
    required this.savedEvents,
    required this.followedOrganizationIds,
    this.onEventSelected,
    this.onToggleSavedEvent,
    this.onToggleFollowedOrganization,
  });

  @override
  // Builds the saved events and followed organizations page
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Saved',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Saved Events',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          if (savedEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No saved events yet'),
            )
          else
            ...savedEvents.map(
                (event) => _SavedEventCard(
                  event: event,
                  onTap: onEventSelected,
                  onToggleSaved: onToggleSavedEvent,
                ),
            ),
          const SizedBox(height: 24),
          Text(
            'Followed Organizations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (followedOrganizationIds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No followed organizations yet'),
            )
          else
            ...followedOrganizationIds.map(
                (orgId) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Organization $orgId'),
                    subtitle: const Text('Followed'),
                    trailing: IconButton(
                      onPressed: () =>
                          onToggleFollowedOrganization?.call(orgId),
                      icon: const Icon(Icons.favorite),
                    ),
                  ),
                ),
            ),
        ],
      ),
    );
  }
}

// Saved event card class
class _SavedEventCard extends StatelessWidget {
  final Event event;
  final void Function(Event event)? onTap;
  final void Function(Event event)? onToggleSaved;

  const _SavedEventCard({
    required this.event,
    this.onTap,
    this.onToggleSaved,
  });

  // Helper for formatting event time of a saved event
  String _formatEventTime(Event event) {
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    return '${dateFormat.format(event.startTime)} • '
        '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}';
  }

  // Helper for building location text for a saved event
  String _buildLocationText(Event event) {
    if (event.location.isOnline) {
      return 'Online Event';
    }

    final parts = <String>[
      event.location.name,
      if (event.location.address != null && event.location.address!.isNotEmpty)
        event.location.address!,
    ];

    return parts.join(' • ');
  }

  @override
  // Builds the saved event card
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => onTap?.call(event),
        leading: event.thumbnailUrl != null && event.thumbnailUrl!.isNotEmpty
          ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              event.thumbnailUrl!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.event),
                );
              },
            ),
          )
          : const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.event),
          ),
        title: Text(event.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_formatEventTime(event)),
            Text(_buildLocationText(event)),
          ],
        ),
        trailing: IconButton(
          onPressed: () => onToggleSaved?.call(event),
          icon: const Icon(Icons.bookmark),
        ),
      ),
    );
  }
}