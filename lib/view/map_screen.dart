
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final LatLng? location;

  const MapScreen({super.key, this.location});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  LatLng? _initialPosition;
  final Set<Marker> _markers = {};

  bool get _isViewing => widget.location != null;

  @override
  void initState() {
    super.initState();
    if (_isViewing) {
      _initialPosition = widget.location;
      _selectedLocation = widget.location;
      if (_selectedLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('event-location'),
            position: _selectedLocation!,
          ),
        );
      }
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _selectedLocation = _initialPosition;
        _markers.add(
          Marker(
            markerId: const MarkerId('selected-location'),
            position: _selectedLocation!,
          ),
        );
      });
    } catch (e) {
      print(e);
      setState(() {
        _initialPosition = const LatLng(38.9637, 35.2433);
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng location) {
    if (_isViewing) return;

    setState(() {
      _selectedLocation = location;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: _selectedLocation!,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isViewing ? 'Etkinlik Konumu' : 'Konum Seç'),
        actions: [
          if (!_isViewing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_selectedLocation != null) {
                  Navigator.of(context).pop(_selectedLocation);
                }
              },
            ),
        ],
      ),
      body: _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition!,
                zoom: 15.0,
              ),
              onTap: _onTap,
              markers: _markers,
              myLocationEnabled: !_isViewing,
              myLocationButtonEnabled: !_isViewing,
            ),
    );
  }
}
