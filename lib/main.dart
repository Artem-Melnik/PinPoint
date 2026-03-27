import 'package:flutter/material.dart';
import 'map_view.dart';
import 'search_view.dart';
import './models/models.dart';

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
  late final List<({IconData icon, IconData activeIcon, String label})>
    _destinations;

  // Handles behavior when an event is selected from the search view
  void _handleSearchEventSelected(Event event) {
    setState(() {
      _selectedIndex = 0;
      _selectedEventFromSearch = event;
    });
  }

  // Builds Google Maps view for homepage
  Widget _buildMapView() {
    return MapView(
      selectedEvent: _selectedEventFromSearch,
    );
  }

  // Builds event search page
  Widget _buildSearchView() {
    return SearchView(
      onEventSelected: _handleSearchEventSelected,
    );
  }

  @override
  // Holds page destinations
  void initState() {
    super.initState();

    _destinations = [
      (
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: "Home",
      ),
      (
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: "Search",
      ),
      (
      icon: Icons.favorite_outlined,
      activeIcon: Icons.favorite,
      label: "Favorites",
      ),
      (
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: "Profile",
      )
    ];
  }

  @override
  // Evaluates whether the layout should be for mobile or desktop
  // Builds corresponding layout
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return isWide ? _buildWideLayout() : _buildNarrowLayout();
        }
    );
  }

  // Building navigation bar and pages for mobile layout
  Widget _buildNarrowLayout() {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildMapView(),
            _buildSearchView(),
            const Center(child: Text('Favorites')),
            const Center(child: Text('Profile')),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: _destinations
              .map((destination) =>
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.activeIcon),
                label: destination.label,
              )).toList(),
        )
    );
  }

  // Builds navigation rail and pages for desktop layout
  Widget _buildWideLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            leading: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add),
            ),
            destinations: _destinations
                .map((destination) =>
                NavigationRailDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.activeIcon),
                  label: Text(destination.label),
                )).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildMapView(),
                _buildSearchView(),
                const Center(child: Text('Favorites')),
                const Center(child: Text('Profile')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
