import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_service.dart';

class GoogleMapServiceImpl implements MapService {
  @override
  void initialize() {
    // API keys are usually configured in AndroidManifest.xml and AppDelegate.swift
    // Additional initialization can be done here if needed.
  }

  @override
  Widget buildMap({
    required double centerLat,
    required double centerLng,
    required List<PlacePointer> markers,
    required Function(String placeId) onMarkerTapped,
  }) {
    final Set<Marker> googleMarkers = markers.map((ptr) {
      return Marker(
        markerId: MarkerId(ptr.id),
        position: LatLng(ptr.latitude, ptr.longitude),
        infoWindow: InfoWindow(title: ptr.title),
        onTap: () => onMarkerTapped(ptr.id),
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(centerLat, centerLng),
        zoom: 14.0,
      ),
      markers: googleMarkers,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
    );
  }
}
