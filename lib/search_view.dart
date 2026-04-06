import 'models/models.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Holds a passed in callback that returns to the map view when an event
// is selected to be shown on the map
class SearchView extends StatefulWidget {
  final void Function(Event event)? onEventSelected;
  final bool embedded;

  const SearchView({
    super.key,
    this.onEventSelected,
    this.embedded = false,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String _query = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Reads events from JSON file (stand-in for database for testing)
  Future<void> _loadEvents() async {
    final String response = await rootBundle.loadString('assets/test_events.json');
    final List<dynamic> decodedJson = json.decode(response);

    final List<Event> loadedEvents = decodedJson
      .map((eventJson) => Event.fromJson(eventJson as Map<String, dynamic>))
      .toList();

    setState(() {
      _allEvents = loadedEvents;
      _filteredEvents = loadedEvents;
      _isLoading = false;
    });

  }

  // Handles filtering displayed events based on user search
  void _filterEvents(String query) {
    final String normalizedQuery = query.toLowerCase().trim();

    setState(() {
      _query = query;

      if (normalizedQuery.isEmpty) {
        _filteredEvents = _allEvents;
        return;
      }

      _filteredEvents = _allEvents.where((event) {
        final String name = event.name.toLowerCase();
        final String description = event.description.toLowerCase();
        final String locationName = event.location.name.toLowerCase();
        final String address = event.location.address!.toLowerCase();
        final String organizationId = event.organizationId.toLowerCase();
        final String status = event.status.name.toLowerCase();

        return name.contains(normalizedQuery) ||
            description.contains(normalizedQuery) ||
            locationName.contains(normalizedQuery) ||
            address.contains(normalizedQuery) ||
            organizationId.contains(normalizedQuery) ||
            status.contains(normalizedQuery);
      }).toList();
    });
  }

  // Helper function to format event time
  String _formatEventTime(Event event) {
    final DateFormat dateFormat = DateFormat('MMM d');
    final DateFormat timeFormat = DateFormat('h:mm a');

    return '${dateFormat.format(event.startTime)} • '
        '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}';
  }

  // Helper function to check if an event can be viewed on the map
  bool _canViewOnMap(Event event) {
    return event.location.latitude != null &&
        event.location.longitude != null &&
        !event.location.isOnline;
  }

  @override
  // Builds search view as either embedded in the map view or as its own page
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        if (widget.embedded)
          Padding (
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Search Events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _filterEvents,
            decoration: InputDecoration(
              hintText: 'Search events, rooms, descriptions...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  _filterEvents('');
                },
                icon: const Icon(Icons.clear),
              ) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredEvents.isEmpty
              ? const Center(
                child: Text(
                  'No events found.\nTry another keyword.',
                  textAlign: TextAlign.center,
                ),
              ) : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = _filteredEvents[index];
                    return _buildEventCard(event);
                  },
                ),
        ),
      ],
    );

    return widget.embedded ? content : SafeArea(child: content);
  }

  // Builds an event card within the search for an existing event
  Widget _buildEventCard(Event event) {
    return InkWell(
      onTap: () => _showEventDetails(event),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.thumbnailUrl != null && event.thumbnailUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.thumbnailUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatEventTime(event),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildLocationText(event),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shows event details in a bottom sheet
  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildEventDetailSheet(event);
      },
    );
  }

  // Helper function to format location text, adapts to online events
  String _buildLocationText(Event event) {
    final location = event.location;

    if (location.isOnline) {
      return 'Online';
    }

    final parts = [
      location.name,
      location.address,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.join(' • ');
  }

  // Helper function to format city, state, zip
  String _buildCityStateZip(Event event) {
    final location = event.location;

    final parts = <String>[];

    final cityState = [
      location.city,
      location.state,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    if (cityState.isNotEmpty) {
      parts.add(cityState);
    }

    if (location.zipCode != null && location.zipCode!.isNotEmpty) {
      parts.add(location.zipCode!);
    }

    return parts.join(' ');
  }

  // Builds the event detail sheet when an event is selected
  Widget _buildEventDetailSheet(Event event) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy');
    final DateFormat timeFormat = DateFormat('h:mm a');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              if (event.thumbnailUrl != null && event.thumbnailUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    event.thumbnailUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        alignment: Alignment.center,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 40),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                event.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 16),
              Text(
                'Date: ${dateFormat.format(event.startTime)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Time: ${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
              ),
              const SizedBox(height: 12),
              Text(
                'Location: ${event.location.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (event.location.isOnline) ...[
                const Text(
                  'Online Event',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                if (event.location.onlineUrl != null && event.location.onlineUrl!.isNotEmpty)
                  Text(event.location.onlineUrl!),
              ] else ...[
                Text(
                  'Location: ${event.location.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (event.location.address != null && event.location.address!.isNotEmpty)
                  Text(event.location.address!),
                Text(_buildCityStateZip(event)),
              ],
              const SizedBox(height: 12),
              Text('Status: ${event.status.name}'),
              Text('Organization ID: ${event.organizationId}'),
              if (event.tagIds.isNotEmpty)
                Text('Tags: ${event.tagIds.join(', ')}'),
              if (event.attendance != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Attendance',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('RSVP Required: ${event.attendance!.requiresRSVP ? 'Yes' : 'No'}'),
                Text('Capacity: ${event.attendance!.maxCapacity}'),
              ],
              const SizedBox(height: 20),
              if (widget.onEventSelected != null && _canViewOnMap(event)) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onEventSelected!(event);
                    },
                    icon: const Icon(Icons.place),
                    label: const Text('View on Map'),
                  )
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}