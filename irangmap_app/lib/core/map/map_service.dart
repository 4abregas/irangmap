import 'package:flutter/material.dart';

class PlacePointer {
  final String id;
  final double latitude;
  final double longitude;
  final String title;

  const PlacePointer({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
  });
}

abstract class MapService {
  void initialize();
  
  Widget buildMap({
    required double centerLat,
    required double centerLng,
    required List<PlacePointer> markers,
    required Function(String placeId) onMarkerTapped,
  });
}
