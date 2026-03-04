import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web/web.dart' as web;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  // final LatLng _center = const LatLng(36.99264793101842, -122.05781821405948);
  //LatLng _center = const LatLng(36.99264793101842, -122.05781821405948);
  LatLng _center = const LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void setCenter() {
    debugPrint("OnCenter");
    setState(() {
      _center = LatLng(36.99264793101842, -122.05781821405948);
      //mapController.moveCamera(CameraUpdate.newLatLng(_center));
      debugPrint("Center: $_center");
    });
  }

  void moveCenter() {
    setState(() {
      _center = LatLng(36.99264793101842, -122.05781821405948);
      debugPrint("MoveCenter");
      mapController.moveCamera(CameraUpdate.newLatLng(_center));
    });

  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Center $_center, building");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
            TextButton(onPressed: setCenter, child: Text("Set to zero"))
            // IconButton.filled(onPressed: setCenter, icon: Icon(Icons.my_location)),
          ],
        ),
        floatingActionButton: FloatingActionButton.large(onPressed: moveCenter, child: Icon(Icons.my_location)),
      ),
    );
  }
}