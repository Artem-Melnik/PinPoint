import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
        home: MainInterface());
  }
}

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  State<MainInterface> createState() => _MainInterfaceState();
}

class _MainInterfaceState extends State<MainInterface> {
  int _selectedIndex = 0;
  late final List<({IconData icon, IconData activeIcon, String label, Widget page})>
    _destinations;

  static const LatLng _center = LatLng(36.99264793101842, -122.05781821405948);
  static const CameraPosition _initialPosition = CameraPosition(target: _center, zoom: 15.0);

  GoogleMapController? _mapController;

  // Builds Google Maps view and implements controller
  Widget _buildMapView() {
    return GoogleMap(
      initialCameraPosition: _initialPosition,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  // Holds page destinations
  @override
  void initState() {
    super.initState();

    _destinations = [
      (
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: "Home",
      page: _buildMapView()
      ),
      (
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: "Search",
      page: const Center(child: Text('Search'))
      ),
      (
      icon: Icons.favorite_outlined,
      activeIcon: Icons.favorite,
      label: "Favorites",
      page: const Center(child: Text('Favorites'))
      ),
      (
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: "Profile",
      page: const Center(child: Text('Profile'))
      )
    ];
  }

  // Evaluates whether the layout should be for Mobile or Desktop
  // Builds corresponding layout
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return isWide ? _buildWideLayout() : _buildNarrowLayout();
        }
    );
  }

  // Building Navigation Bar and Pages for Mobile
  Widget _buildNarrowLayout() {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _destinations.map((destination) => destination.page).toList()
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

  // Building Navigation Rail and Page for Desktop
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
              children: _destinations.map((destination) => destination.page).toList()
            ),
          ),
        ],
      ),
    );
  }
}
