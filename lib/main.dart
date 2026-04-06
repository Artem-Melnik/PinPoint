import 'package:flutter/material.dart';
import 'map_view.dart';
import 'search_view.dart';
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

  static const double _desktopBreakpoint = 900;

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
    final Widget map = MapView(
      selectedEvent: _selectedEventFromSearch,
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
              onEventSelected: _handleSearchEventSelected,
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
    return SearchView(
      onEventSelected: _handleSearchEventSelected,
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
          leading: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
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
