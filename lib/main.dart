import 'package:flutter/material.dart';
import 'map_view.dart';
import 'search_view.dart';
import 'event_form_dialog.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'models/models.dart';
import 'models/app_destination.dart';

void main() {
  runApp(const PinPointApp());
}

class PinPointApp extends StatelessWidget {
  const PinPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "PinPoint",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: const MainInterface());
  }
}

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  State<MainInterface> createState() => _MainInterfaceState();
}

class _MainInterfaceState extends State<MainInterface> {
  Event? _selectedEventFromSearch;
  int _selectedIndex = 0;

  List<Event> _events =[];
  bool _isLoadingEvents = true;
  bool _isEventDialogOpen = false;

  MemberRole _currentUserRole = MemberRole.admin;

  static const double _desktopBreakpoint = 900;

  bool _canManageEvents() {
    return _currentUserRole == MemberRole.owner ||
      _currentUserRole == MemberRole.admin;
  }

  bool _isOwner() {
    return _currentUserRole == MemberRole.owner;
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }

  // Handles behavior when an event is selected from the search view
  void _handleSearchEventSelected(Event event) {
    setState(() {
      _selectedIndex = 0;
      _selectedEventFromSearch = event;
    });
  }

  // Builds Google Maps view for homepage
  Widget _buildMapView(BuildContext context) {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    final Widget map = MapView(
      events: _events,
      selectedEvent: _selectedEventFromSearch,
      isInteractionLocked: _isEventDialogOpen,
      canManageEvents: _canManageEvents(),
      onEditEvent: _openEditEventDialog,
      onDeleteEvent: _confirmDeleteEvent,
    );

    if (!_isDesktop(context)) {
      return map;
    }

    return Row(
      children: [
        SizedBox(
          width: 380,
          child: Material(
            elevation: 2,
            color: Theme.of(context).colorScheme.surface,
            child: SearchView(
              events: _events,
              onEventSelected: _handleSearchEventSelected,
              canManageEvents: _canManageEvents(),
              onEditEvent: _openEditEventDialog,
              onDeleteEvent: _confirmDeleteEvent,
              embedded: true,
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: map),
      ],
    );
  }

  // Builds event search page
  Widget _buildSearchView() {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    return SearchView(
      events: _events,
      onEventSelected: _handleSearchEventSelected,
      canManageEvents: _canManageEvents(),
      onEditEvent: _openEditEventDialog,
      onDeleteEvent: _confirmDeleteEvent,
    );
  }

  // Page building handler
  List<Widget> _buildPages(BuildContext context) {
    final isDesktop = _isDesktop(context);

    return [
      _buildMapView(context),
      if (!isDesktop) _buildSearchView(),
      const Center(child: Text('Favorites')),
      const Center(child: Text('Profile')),
    ];
  }

  // Builds page destination objects
  List<AppDestination> _buildDestinations(BuildContext context) {
    final isDesktop = _isDesktop(context);

    return [
      AppDestination(
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        label: "Home",
      ),
      if (!isDesktop)
        AppDestination(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: "Search",
        ),
      AppDestination(
        icon: Icons.favorite_outlined,
        activeIcon: Icons.favorite,
        label: "Favorites",
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Loads events from JSON file (for test purposes)
  Future<void> _loadEvents() async {
    try {
      final String response = await rootBundle.loadString('assets/test_events.json');
      final List<dynamic> decodedJson = json.decode(response) as List<dynamic>;

      final List<Event> loadedEvents = decodedJson
          .map((item) => Event.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      setState(() {
        _events = loadedEvents;
        _isLoadingEvents = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading events: $e');
      debugPrintStack(stackTrace: stackTrace);

      setState(() {
        _isLoadingEvents = false;
      });
    }
  }

  // Event creation handler
  void _createEvent(Event event) {
    setState(() {
      _events = [..._events, event]
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  // Event updating handler
  void _updateEvent(Event updatedEvent) {
    setState(() {
      _events = _events
          .map((event) => event.id == updatedEvent.id ? updatedEvent : event)
          .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  // Event deletion handler
  void _deleteEvent(String eventId) {
    setState(() {
      _events = _events.where((event) => event.id != eventId).toList();
    });
  }

  // Event creation dialog handler
  Future<void> _openCreateEventDialog() async {
    setState(() {
      _isEventDialogOpen = true;
    });

    final Event? createdEvent = await showDialog<Event>(
      context: context,
      builder: (context) => const EventFormDialog(),
    );

    if (!mounted) return;

    setState(() {
      _isEventDialogOpen = false;
    });

    if (createdEvent != null) {
      _createEvent(createdEvent);
    }
  }

  // Event editing dialog handler
  Future<void> _openEditEventDialog(Event event) async {
    setState(() {
      _isEventDialogOpen = true;
    });

    final Event? updatedEvent = await showDialog<Event>(
      context: context,
      builder: (context) => EventFormDialog(initialEvent: event),
    );

    if (!mounted) return;

    setState(() {
      _isEventDialogOpen = false;
    });

    if (updatedEvent != null) {
      _updateEvent(updatedEvent);
    }
  }

  // Event deletion confirmation dialog handler
  Future<bool> _confirmDeleteEvent(Event event) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "${event.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      }
    );

    if (confirmed == true) {
      _deleteEvent(event.id);
      return true;
    }

    return false;
  }

  @override
  // Evaluates whether the layout should be for mobile or desktop
  // Builds corresponding layout
  Widget build(BuildContext context) {
    final destinations = _buildDestinations(context);
    final pages = _buildPages(context);

    final safeSelectedIndex =
      _selectedIndex >= pages.length ? 0 : _selectedIndex;

    final useRail = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      body: useRail
          ? _buildWideLayout(
              context,
              destinations,
              pages,
              safeSelectedIndex,
            )
          : _buildNarrowLayout(
              context,
              destinations,
              pages,
              safeSelectedIndex,
            ),
      bottomNavigationBar: useRail
        ? null
        : _buildBottomNav(
            destinations,
            safeSelectedIndex,
          ),
      floatingActionButton: _canManageEvents()
        ? FloatingActionButton(
          onPressed: _openCreateEventDialog,
          child: const Icon(Icons.add),
        )
        : null,
    );
  }

  // Building bottom navigation bar
  Widget _buildBottomNav(
      List<AppDestination> destinations,
      int selectedIndex,
      ) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) =>
          setState(() => _selectedIndex = index),
      destinations: destinations
          .map(
            (destination) =>
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.activeIcon),
              label: destination.label,
            ),
      ).toList(),
    );
  }

  // Building navigation bar and pages for mobile layout
  Widget _buildNarrowLayout(
      BuildContext context,
      List<AppDestination> destinations,
      List<Widget> pages,
      int selectedIndex,
      ) {
        return IndexedStack(
          index: selectedIndex,
          children: pages,
        );
  }

  // Builds navigation rail and pages for desktop layout
  Widget _buildWideLayout(
      BuildContext context,
      List<AppDestination> destinations,
      List<Widget> pages,
      int selectedIndex,
      ) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          labelType: NavigationRailLabelType.all,
          destinations: destinations
              .map(
                  (destination) => NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.activeIcon),
                    label: Text(destination.label),
                  ),
              ).toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: pages,
          ),
        ),
      ],
    );
  }
}
