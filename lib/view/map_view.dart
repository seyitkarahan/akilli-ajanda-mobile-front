
import 'dart:ui' as ui;

import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key, required this.viewModel}) : super(key: key);
  final HomeViewModel viewModel;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _createCustomMarkers();
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(String title) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: 250);
    final double width = textPainter.width + 30;
    final double height = textPainter.height + 20;

    final Paint paint = Paint()..color = Colors.deepPurple;
    final RRect rrect = RRect.fromLTRBR(0, 0, width, height, const Radius.circular(15));
    canvas.drawRRect(rrect, paint);

    textPainter.paint(canvas, const Offset(15, 10));

    final img = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  void _createCustomMarkers() async {
    final List<EventResponse> eventsWithLocation = widget.viewModel.events
        .where((event) => event.latitude != null && event.longitude != null)
        .toList();

    for (final event in eventsWithLocation) {
      final markerIcon = await _createCustomMarkerBitmap(event.title);
      _markers.add(
        Marker(
          markerId: MarkerId('event_${event.id}'),
          position: LatLng(event.latitude!, event.longitude!),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: event.title,
            snippet: event.location,
          ),
        ),
      );
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik Haritası'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _markers.isNotEmpty
                    ? _markers.first.position
                    : const LatLng(38.9637, 35.2433), // Default to Turkey
                zoom: _markers.isNotEmpty ? 10.0 : 5.0,
              ),
              markers: _markers,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
    );
  }
}
