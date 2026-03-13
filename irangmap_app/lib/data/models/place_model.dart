import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> facilities;
  final String priceType;
  final List<String> ageTags;
  final bool isOpen;
  final double score;

  PlaceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.facilities,
    required this.priceType,
    required this.ageTags,
    required this.isOpen,
    required this.score,
  });

  factory PlaceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    GeoPoint geoPoint = data['location'] ?? const GeoPoint(0, 0);

    return PlaceModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
      address: data['address']?['detail'] ?? '',
      facilities: List<String>.from(data['facilities'] ?? []),
      priceType: data['priceType'] ?? 'free',
      ageTags: List<String>.from(data['ageTags'] ?? []),
      isOpen: data['isOpen'] ?? true,
      score: (data['score'] ?? 0).toDouble(),
    );
  }
}
