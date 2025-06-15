import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecosnap_1/common/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// A model for our location markers
class LocationMarker {
  final String id;
  final String title;
  final String snippet;
  final LatLng position;

  LocationMarker({
    required this.id,
    required this.title,
    required this.snippet,
    required this.position,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(17.3850, 78.4867), // Default to Hyderabad
    zoom: 12,
  );

  final Set<Marker> _markers = {};
  LocationMarker? _selectedMarker;
  String _currentLocationName = "Locating...";
  String _currentWeather = "--°C";

  // Predefined locations around Hyderabad
  final List<LocationMarker> _sampleLocations = [
    LocationMarker(
        id: '1',
        title: 'Eco-garden',
        snippet: 'A habitat for a lot of gatherings endoring biodiversity.',
        position: const LatLng(17.352565, 78.354729)),
    LocationMarker(
        id: '2',
        title: 'Recycling Plant',
        snippet: 'Offers various services for recycling purposes.',
        position: const LatLng(17.343747, 78.373831)),
    LocationMarker(
        id: '3',
        title: 'Himayat Sagar Crowd Run',
        snippet: 'This is a large run with a stretch of 1km.',
        position: const LatLng(17.333051, 78.364343)),
    LocationMarker(
        id: '4',
        title: 'Waste Disposal',
        snippet: 'Features various kinds of waste disposal methods.',
        position: const LatLng(17.328604, 78.373271)),
  ];

  @override
  void initState() {
    super.initState();
    _setMarkers();
    _determinePosition();
  }

  void _setMarkers() {
    for (final location in _sampleLocations) {
      _markers.add(
        Marker(
          markerId: MarkerId(location.id),
          position: location.position,
          // We use the custom pop-up card instead of the default InfoWindow
          onTap: () {
            setState(() {
              _selectedMarker = location;
            });
          },
        ),
      );
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable them.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // In a real app, you would fetch location name and weather from APIs.
    setState(() {
      _currentLocationName = "Hyderabad"; // Placeholder
      _currentWeather = "31°C"; // Placeholder
    });
    _goToPosition(position);
  }

  Future<void> _goToPosition(Position position) async {
    final GoogleMapController controller = await _controller.future;
    final newPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.5,
      tilt: 45.0,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            onTap: (LatLng position) {
              setState(() {
                _selectedMarker = null;
              });
            },
          ),
          _buildUiControls(),
          if (_selectedMarker != null)
            Positioned(
              bottom: 120, // Position above the bottom controls
              left: 20,
              right: 20,
              child: _buildInfoCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildUiControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTopControls(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildCircularButton(icon: Icons.person_outline, color: primary),
            const SizedBox(width: 10),
            _buildCircularButton(icon: Icons.search),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              spreadRadius: 15,
              blurRadius: 30,
            ),
          ]),
          child: Column(
            children: [
              Text(
                _currentLocationName,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.cloud_outlined, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _currentWeather,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  )
                ],
              )
            ],
          ),
        ),
        _buildCircularButton(icon: Icons.settings_outlined),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildLabeledAvatar(label: "My Bitmoji", icon: Icons.face),
        GestureDetector(
          onTap: _determinePosition, // Center on user location
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.location_searching, size: 24, color: black),
          ),
        ),
        _buildLabeledAvatar(label: "Friends", icon: Icons.people_outline),
      ],
    );
  }

  Widget _buildCircularButton({required IconData icon, Color? color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.4),
      ),
      child: Icon(
        icon,
        color: color ?? Colors.white,
        size: 23,
      ),
    );
  }

  Widget _buildLabeledAvatar({required String label, required IconData icon}) {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: white),
            child: Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: Icon(icon, color: Colors.grey.shade800, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.9),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedMarker!.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMarker = null;
                    });
                  },
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedMarker!.snippet,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () { /* TODO: Implement navigation or other action */ },
              child: const Text('View Details'),
            )
          ],
        ),
      ),
    );
  }
}
