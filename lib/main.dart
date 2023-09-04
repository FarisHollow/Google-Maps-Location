import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

/// API keu - AIzaSyB7w8JhkAHJJkhweXYfp7w_28JRYI6o8zg


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
const double DEFAULT_LATITUDE = 0.0;
const double DEFAULT_LONGITUDE = 0.0;

class _HomeScreenState extends State<HomeScreen> {
  late final GoogleMapController _googleMapController;
  LocationData? myCurrentLocation;
  StreamSubscription? _locationSubscription;
  bool isTracking = false;



  void getMyLocation() async {
    await Location.instance.requestPermission().then((requestedPermission) {
      print(requestedPermission);
    });
    await Location.instance.hasPermission().then((permissionStatus)  {
      print(permissionStatus);
    });
    myCurrentLocation = await Location.instance.getLocation();
    print(myCurrentLocation);
    if (mounted) {
      setState(() {});
    }
  }

  List<LatLng> polylinePoints = [];

  void listenToMyLocation() {
    _locationSubscription =
        Location.instance.onLocationChanged.listen((location) {
          if (location != myCurrentLocation) {
            myCurrentLocation = location;
            print('listening to location $location');
            if (mounted) {
              setState(() {
                polylinePoints.add(LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0));
              });
            }
          }
        });

    // Show the Snackbar when tracking starts
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Started tracking'),
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {
      isTracking = true;
    });
  }

  void stopToListenLocation() {
    _locationSubscription?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stopped tracking'),
        duration: Duration(seconds: 2),
      ),
    );

    // Update the tracking status
    setState(() {
      isTracking = false;
    });
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() {
    Location.instance.changeSettings(
        distanceFilter: 1,
        accuracy: LocationAccuracy.high,
        interval: 1000
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google map location tracker'),
        backgroundColor: Colors.teal,
      ),
      body: GoogleMap(
        initialCameraPosition:  const CameraPosition(
          zoom: 5,
          bearing: 30,
          tilt: 10,
          target: LatLng(24.250151813382207, 89.92231210838047),
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        trafficEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          print('on map created');
          _googleMapController = controller;
        },
        compassEnabled: true,
        onTap: (LatLng l) {
          print(l);
        },
        onLongPress: (LatLng l) {
          print(l);
        },
        mapType: MapType.normal,
        markers: <Marker>{
          Marker(
              markerId: const MarkerId('custom-marker'),
              position: LatLng(
                myCurrentLocation?.latitude ?? DEFAULT_LATITUDE,
                myCurrentLocation?.longitude ?? DEFAULT_LONGITUDE,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: 'My Current Location',
                snippet: "Latitude: ${myCurrentLocation?.latitude}, " " Longitude: ${myCurrentLocation?.longitude}", ),
              draggable: true,
              // draggable: true,
              onDragStart: (LatLng latLng) {
                print(latLng);
              },
              onDragEnd: (LatLng latLng) {
                print(latLng);
              }
          ),

        },
        polylines: <Polyline> {
          Polyline(polylineId: PolylineId('polyline'),
              color: Colors.cyan,
              width: 5,
              jointType: JointType.round,
              onTap: (){
                print('Tapped on polyline');
              },
              points: polylinePoints
          ),
        },
        circles: <Circle>{
          Circle(
            circleId: const CircleId('circle'),
            center: LatLng(
              myCurrentLocation?.latitude ?? DEFAULT_LATITUDE,
              myCurrentLocation?.longitude ?? DEFAULT_LONGITUDE,
            ),
            radius: 4,
            strokeColor: Colors.teal,
            strokeWidth:2,
            fillColor: Colors.purple.shade100,
            onTap: () {
              print('Tapped on circle');
            },
          ),
        },

      ),
      floatingActionButton:   Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (isTracking) {
                stopToListenLocation();
              } else {
                listenToMyLocation();
              }
            },
            child: Icon(isTracking ? Icons.stop_circle_outlined : Icons.location_history),
          ),
          const SizedBox(width: 8,),
          FloatingActionButton(
            onPressed: () {
              getMyLocation();
            },
            child: const Icon(Icons.my_location),
          ),

        ],
      ),

    );
  }
  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}