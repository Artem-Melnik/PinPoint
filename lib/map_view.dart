import 'models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:js_interop';

@JS('GOOGLE_MAP_ID')
external String? get googleMapId;

// Holds selectedEvent if an event is selected from the search view
class MapView extends StatefulWidget {
  final List<Event> events;
  final Event? selectedEvent;
  final bool isInteractionLocked;
  final ValueChanged<Event>? onEventSelected;
  final VoidCallback? onClearSelectedEvent;
  final bool canManageEvents;
  final void Function(Event event)? onEditEvent;
  final Future<bool> Function(Event event)? onDeleteEvent;
  final bool Function(Event event)? isEventSaved;
  final void Function(Event event)? onToggleSavedEvent;
  final bool Function(String organizationId)? isOrganizationFollowed;
  final void Function(String organizationId)? onToggleFollowedOrganization;

  const MapView({
    super.key,
    required this.events,
    this.selectedEvent,
    this.isInteractionLocked = false,
    this.onEventSelected,
    this.onClearSelectedEvent,
    this.canManageEvents = false,
    this.onEditEvent,
    this.onDeleteEvent,
    this.isEventSaved,
    this.onToggleSavedEvent,
    this.isOrganizationFollowed,
    this.onToggleFollowedOrganization,
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
  Set<AdvancedMarker> _markers = {};

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
          if (widget.onClearSelectedEvent != null) {
            widget.onClearSelectedEvent!();
          } else {
            setState(() {
              _selectedEvent = null;
            });
          }
        } else {
          if (widget.onEventSelected != null) {
            widget.onEventSelected!(matchingEvent.first);
          } else {
            setState(() {
              _selectedEvent = matchingEvent.first;
            });
          }
        }
      }
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
    final Set<AdvancedMarker> loadedMarkers = widget.events
        .where(_eventHasMapLocation)
        .map((event) {
          return AdvancedMarker(
            markerId: MarkerId(event.id),
            position: LatLng(
              event.location.latitude!,
              event.location.longitude!,
            ),
            onTap: () {
              if (widget.onEventSelected != null) {
                widget.onEventSelected!(event);
              } else {
                setState(() {
                  _selectedEvent = event;
                });
              }
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
      location.latitude!,
      location.longitude!,
    );

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 20),
    );

    if (widget.onEventSelected != null) {
      widget.onEventSelected!(event);
    } else {
      setState(() {
        _selectedEvent = event;
      });
    }
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
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.thumbnailUrl != null && event.thumbnailUrl!.isNotEmpty)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              event.thumbnailUrl!,
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              elevation: 4,
                              color: Colors.black54,
                              shape: const CircleBorder(),
                              child: IconButton(
                                onPressed: () {
                                  widget.onToggleSavedEvent?.call(event);
                                },
                                icon: Icon(
                                  widget.isEventSaved?.call(event) == true
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

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
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () =>
                          widget.onToggleFollowedOrganization?.call(event.organizationId),
                      icon: Icon(
                        widget.isOrganizationFollowed?.call(event.organizationId) == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        widget.isOrganizationFollowed?.call(event.organizationId) == true
                            ? 'Unfollow Organization'
                            : 'Follow Organization',
                      ),
                    ),
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
              Positioned(
                top: 8,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (widget.onClearSelectedEvent != null) {
                      widget.onClearSelectedEvent!();
                    } else {
                      setState(() {
                        _selectedEvent = null;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the side panel for a selected event (if on desktop)
  Widget _buildSidePanel(Event event) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.thumbnailUrl != null && event.thumbnailUrl!.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      event.thumbnailUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      elevation: 4,
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () {
                          widget.onToggleSavedEvent?.call(event);
                        },
                        icon: Icon(
                          widget.isEventSaved?.call(event) == true
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (widget.onClearSelectedEvent != null) {
                      widget.onClearSelectedEvent!();
                    } else {
                      setState(() {
                        _selectedEvent = null;
                      });
                    }
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(event.description),

            const SizedBox(height: 16),
            Text(
              'Time: ${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
            ),

            const SizedBox(height: 8),
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

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () =>
                  widget.onToggleFollowedOrganization?.call(event.organizationId),
              icon: Icon(
                widget.isOrganizationFollowed?.call(event.organizationId) == true
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              label: Text(
                widget.isOrganizationFollowed?.call(event.organizationId) == true
                    ? 'Following Org'
                    : 'Follow Org',
              ),
            ),

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
                    child: FilledButton.tonalIcon(
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
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final bool isDetailsOpen = isDesktop && (widget.selectedEvent != null || _selectedEvent != null);
    final bool shouldLockMap = widget.isInteractionLocked || isDetailsOpen;
    final Event? activeEvent = widget.selectedEvent ?? _selectedEvent;

    final mapWidget = Stack(
      children: [
        AbsorbPointer(
          absorbing: shouldLockMap,
          child: GoogleMap(
            mapId: kIsWeb ? googleMapId : null,
            markerType: GoogleMapMarkerType.advancedMarker,
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) {
              _mapController = controller;
              _tryFocusSelectedEvent();
            },
            markers: _markers,
            zoomControlsEnabled: false,
            webCameraControlEnabled: false,
            myLocationEnabled: false,
            zoomGesturesEnabled: !shouldLockMap,
            scrollGesturesEnabled: !shouldLockMap,
            tiltGesturesEnabled: !shouldLockMap,
            rotateGesturesEnabled: !shouldLockMap,
            //gestureRecognizers: shouldLockMap ? <Factory<OneSequenceGestureRecognizer>>{} : null,
            onTap: shouldLockMap ? null : (_) {
              if (widget.onClearSelectedEvent != null) {
                widget.onClearSelectedEvent!();
              } else {
                setState(() {
                  _selectedEvent = null;
                });
              }
            },
          ),
        ),

        if (shouldLockMap)
          Positioned.fill(child: Container(
              color: Colors.black.withValues(alpha: 0.05)),
          ),
      ],
    );

    if (!isDesktop) {
      return Stack(
        children: [
          mapWidget,
          // If an event is selected, display its card
          if(activeEvent != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: LimitedBox(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
                child: _buildEventCard(activeEvent),
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: mapWidget),
        if (activeEvent != null) ...[
          const VerticalDivider(thickness: 1, width: 1),
          SizedBox(
            width: 380,
            child: _buildSidePanel(activeEvent),
          ),
        ],
      ],
    );
  }
}