// map_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  final Position? currentPosition;
  final Set<Marker> markers;
  final Completer<GoogleMapController> controller;
  final Function(String name, String address, String openTime, String imageUrl, String category) onMarkerTapped;

  MapWidget({
    required this.currentPosition,
    required this.markers,
    required this.controller,
    required this.onMarkerTapped,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.currentPosition == null
        ? Center(child: CircularProgressIndicator())
        : GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
        zoom: 14.0,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapToolbarEnabled: false,
      markers: widget.markers,
      onMapCreated: (GoogleMapController controller) {
        widget.controller.complete(controller);
      },
    );
  }
}
