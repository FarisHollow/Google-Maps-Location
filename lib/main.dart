import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  Location location = Location();
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  Marker? currentLocationMarker;
  Timer? locationTimer; // Timer for periodic location updates

  @override
  void initState() {
    super.initState();

    // Fetch the initial location.
    fetchLocation();

    // Start a Timer to fetch location updates every 5 seconds
    locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getLocationUpdate();
    });
  }

  void fetchLocation() async {
    currentLocation = await location.getLocation();
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  void getLocationUpdate() async {
    LocationData locationData = await location.getLocation();
    setState(() {
      currentLocation = locationData;
      updatePolyline(locationData);
      updateMarker(locationData);
    });
  }

  void updatePolyline(LocationData locationData) {
    polylineCoordinates.add(LatLng(locationData.latitude!, locationData.longitude!));
    polylines.add(
      Polyline(
        polylineId: const PolylineId("poly"),
        color: Colors.blue,
        points: polylineCoordinates,
      ),
    );
  }

  void updateMarker(LocationData locationData) {
    currentLocationMarker = Marker(
      markerId: const MarkerId("current_location"),
      position: LatLng(locationData.latitude!, locationData.longitude!),
      infoWindow: InfoWindow(
        title: "My current location",
        snippet:
        "Lat: ${locationData.latitude!.toStringAsFixed(6)}, Lng: ${locationData.longitude!.toStringAsFixed(6)}",
      ),
    );
  }

  void resetPolyline() {
    setState(() {
      polylineCoordinates.clear();
      polylines.clear();
    });
  }

  @override
  void dispose() {
    locationTimer?.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location Tracking'),
      ),
      body: currentLocation == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 15.0,
        ),
        myLocationEnabled: true,
        markers: Set.of((currentLocationMarker != null) ? [currentLocationMarker!] : []),
        polylines: polylines,
        zoomControlsEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          resetPolyline();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
