
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key, required this.viewModel}) : super(key: key);
  final HomeViewModel viewModel;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  GoogleMapController? _mapController;
  EventResponse? _selectedEvent;
  bool _showEventList = false;
  final List<EventResponse> _eventsWithLocation = [];

  @override
  void initState() {
    super.initState();
    _createCustomMarkers();
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(String title, Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    
    // Draw pin shape
    final Paint pinPaint = Paint()..color = color;
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Draw shadow
    canvas.drawCircle(const Offset(25, 25), 20, shadowPaint);
    
    // Draw pin circle
    canvas.drawCircle(const Offset(25, 25), 18, pinPaint);
    
    // Draw white border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(25, 25), 18, borderPaint);
    
    // Draw icon
    final iconPaint = Paint()..color = Colors.white;
    final iconPath = Path()
      ..moveTo(25, 15)
      ..lineTo(20, 20)
      ..lineTo(30, 20)
      ..close();
    canvas.drawPath(iconPath, iconPaint);

    final img = await pictureRecorder.endRecording().toImage(50, 50);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  void _createCustomMarkers() async {
    _eventsWithLocation.clear();
    _eventsWithLocation.addAll(
      widget.viewModel.events
          .where((event) => event.latitude != null && event.longitude != null)
          .toList(),
    );

    final List<Color> colors = [
      Colors.deepPurple.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
      Colors.teal.shade400,
    ];

    for (int i = 0; i < _eventsWithLocation.length; i++) {
      final event = _eventsWithLocation[i];
      final color = colors[i % colors.length];
      final markerIcon = await _createCustomMarkerBitmap(event.title, color);
      
      _markers.add(
        Marker(
          markerId: MarkerId('event_${event.id}'),
          position: LatLng(event.latitude!, event.longitude!),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: event.title,
            snippet: event.location,
          ),
          onTap: () {
            setState(() {
              _selectedEvent = event;
            });
          },
        ),
      );
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _fitBounds() {
    if (_markers.isEmpty || _mapController == null) return;
    
    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (var marker in _markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.1, minLng - 0.1),
          northeast: LatLng(maxLat + 0.1, maxLng + 0.1),
        ),
        100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Etkinlik Haritası'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_eventsWithLocation.isNotEmpty)
            IconButton(
              icon: Icon(_showEventList ? Icons.map : Icons.list),
              onPressed: () {
                setState(() {
                  _showEventList = !_showEventList;
                });
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            'Harita yükleniyor...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _markers.isNotEmpty
                                ? _markers.first.position
                                : const LatLng(38.9637, 35.2433),
                            zoom: _markers.isNotEmpty ? 10.0 : 5.0,
                          ),
                          markers: _markers,
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          mapType: MapType.normal,
                          zoomControlsEnabled: false,
                        ),
                        if (_eventsWithLocation.isNotEmpty)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.white,
                              onPressed: _fitBounds,
                              child: Icon(
                                Icons.fit_screen,
                                color: Colors.deepPurple.shade400,
                              ),
                            ),
                          ),
                      ],
                    ),
              if (_showEventList && _eventsWithLocation.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildEventList(),
                ),
              if (_selectedEvent != null)
                Positioned(
                  bottom: _showEventList ? 200 : 20,
                  left: 16,
                  right: 16,
                  child: _buildEventCard(_selectedEvent!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(EventResponse event) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple.shade400, Colors.blue.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (event.location.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedEvent = null;
                        });
                      },
                    ),
                  ],
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${formatter.format(event.startTime)} - ${formatter.format(event.endTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple.shade400, Colors.blue.shade400],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.list,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Etkinlikler (${_eventsWithLocation.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _eventsWithLocation.length,
                  itemBuilder: (context, index) {
                    final event = _eventsWithLocation[index];
                    return _buildEventListItem(event);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventListItem(EventResponse event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade300, Colors.blue.shade300],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.event,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          event.location,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          setState(() {
            _selectedEvent = event;
            _showEventList = false;
          });
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(event.latitude!, event.longitude!),
              15.0,
            ),
          );
        },
      ),
    );
  }
}
