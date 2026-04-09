import 'models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

// Holds selectedEvent if an event is selected from the search view
class MapView extends StatefulWidget {
  final List<Event> events;
  final Event? selectedEvent;
  final bool isInteractionLocked;
  final bool canManageEvents;
  final void Function(Event event)? onEditEvent;
  final Future<bool> Function(Event event)? onDeleteEvent;

  const MapView({
    super.key,
    required this.events,
    this.selectedEvent,
    this.isInteractionLocked = false,
    this.canManageEvents = false,
    this.onEditEvent,
    this.onDeleteEvent,
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
    _rebuildMarkers();
  }

  @override
  // Updates markers when passed in events change
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.events != widget.events) {
      _rebuildMarkers();

      if (_selectedEvent != null) {
          final matchingEvent = widget.events.where(
                (event) => event.id == _selectedEvent!.id,
          );

          if (matchingEvent.isEmpty) {
            setState((){
              _selectedEvent = null;
            });
          } else {
            setState(() {
              _selectedEvent = matchingEvent.first;
            });
          }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryFocusSelectedEvent();
      });
    }

    if (widget.selectedEvent?.id != oldWidget.selectedEvent?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryFocusSelectedEvent();
      });
    }
  }

  // Checks if an event has a map location
  bool _eventHasMapLocation(Event event) {
    final location = event.location;
    return location.latitude != null &&
      location.longitude != null &&
      !location.isOnline;
  }

  // Rebuilds markers for events from passed events param
  Future<void> _rebuildMarkers() async {
    final Set<Marker> loadedMarkers = widget.events
        .where(_eventHasMapLocation)
        .map((event) {
          return Marker(
            markerId: MarkerId(event.id),
            position: LatLng(
              event.location.latitude!,
              event.location.longitude!,
            ),
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
            if (widget.canManageEvents) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onEditEvent?.call(event),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await widget.onDeleteEvent?.call(event);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
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
        IgnorePointer(
          ignoring: widget.isInteractionLocked,
          child: GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) {
              _mapController = controller;
              _tryFocusSelectedEvent();
            },
            markers: _markers,
            zoomControlsEnabled: false,
            webCameraControlEnabled: false,
            myLocationEnabled: false,
            zoomGesturesEnabled: !widget.isInteractionLocked,
            scrollGesturesEnabled: !widget.isInteractionLocked,
            tiltGesturesEnabled: !widget.isInteractionLocked,
            rotateGesturesEnabled: !widget.isInteractionLocked,
            onTap: widget.isInteractionLocked ? null : (_) {
              setState(() {
                _selectedEvent = null;
              });
            },
          ),
        ),

        if (widget.isInteractionLocked)
          Positioned.fill(child: Container(
              color: Colors.black.withOpacity(0.05)),
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