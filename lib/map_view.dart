import 'models/models.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

// Holds selectedEvent if an event is selected from the search view
class MapView extends StatefulWidget {
  final Event? selectedEvent;

  const MapView({
    super.key,
    this.selectedEvent,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const LatLng _center = LatLng(36.99264793101842, -122.05781821405948);
  static const CameraPosition _initialPosition = CameraPosition(target: _center, zoom: 15.0);
  final timeFormat = DateFormat('MMM d, h:mm a');

  GoogleMapController? _mapController;
  Event? _selectedEvent;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  // Checks if an event has a map location
  bool _eventHasMapLocation(Event event) {
    final location = event.location;
    return location.latitude != null &&
      location.longitude != null &&
      !location.isOnline;
  }

  // Loads markers for events from JSON file (stand-in for database for testing)
  Future<void> _loadMarkers() async {
    final String response = await rootBundle.loadString('assets/test_events.json');
    final List<dynamic> decodedJson = json.decode(response);

    final List<Event> loadedEvents = decodedJson
      .map((eventJson) => Event.fromJson(eventJson as Map<String, dynamic>))
      .toList();

    final Set<Marker> loadedMarkers = loadedEvents
        .where(_eventHasMapLocation)
        .map((event) {
      return Marker(
        markerId: MarkerId(event.id),
        position: LatLng(
            event.location.latitude!,
            event.location.longitude!),
        onTap: () {
          setState(() {
            _selectedEvent = event;
          });
        }
      );
    }).toSet();

    setState(() {
      _markers = loadedMarkers;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryFocusSelectedEvent();
    });
  }

  @override
  // If a new selected event is passed, attempts to focus on it
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedEvent?.id != oldWidget.selectedEvent?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryFocusSelectedEvent();
      });
    }
  }

  // Runs checks on an event before it is passed to be focused on in map view
  void _tryFocusSelectedEvent() {
    final event = widget.selectedEvent;

    if (event == null) return;
    if (_mapController == null) return;
    if (_markers.isEmpty) return;

    _focusOnSelectedEvent(event);
  }

  // Handles focusing on the selected event
  Future<void> _focusOnSelectedEvent(Event event) async {
    final location = event.location;
    final LatLng target = LatLng(
      location.latitude! - 0.0001,
      location.longitude!,
    );

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 20),
    );

    setState(() {
      _selectedEvent = event;
    });
  }

  // Builds the details card for a selected event
  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.resolvedThumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.resolvedThumbnail!,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            if (event.resolvedThumbnail != null)
              const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedEvent = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              event.description,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 10),

            Text(
              'Time: ${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
            ),

            const SizedBox(height: 6),

            Text(
              'Location: ${event.location.formattedAddress}',
            ),

            const SizedBox(height: 6),

            Text(
              'Organization ID: ${event.organizationId}',
            ),

            if (event.attendance != null) ...[
              const SizedBox(height: 6),

              Text(
                'Attendance: ${event.attendance!.goingCount} going, ${event.attendance!.maybeCount} maybe, ${event.attendance!.checkedInCount} checked in',
              ),

              if (event.attendance!.requiresRSVP) ...[
                Text(
                  'RSVPs required',
                ),
              ],
              Text(
                'Capacity: ${event.attendance!.maxCapacity}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  // Builds the map view with event markers
  Widget build(BuildContext context) {
    return Stack (
      children: [
        GoogleMap(
          initialCameraPosition: _initialPosition,
          onMapCreated: (controller) {
            _mapController = controller;
            _tryFocusSelectedEvent();
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
        ),

        // If an event is selected, display its card
        if (_selectedEvent != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildEventCard(_selectedEvent!),
          ),
      ],
    );
  }
}