import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/map/map_service.dart';
import '../../core/map/google_map_service_impl.dart';
import '../../data/models/place_model.dart';

// Firestore Realtime Stream
final placesStreamProvider = StreamProvider<List<PlaceModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('places')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => PlaceModel.fromFirestore(doc)).toList());
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final MapService _mapService;

  @override
  void initState() {
    super.initState();
    _mapService = GoogleMapServiceImpl();
    _mapService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final placesAsyncValue = ref.watch(placesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('아이랑맵 코스탐색'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter settings
            },
          )
        ],
      ),
      body: placesAsyncValue.when(
        data: (places) {
          final markers = places.map((p) => PlacePointer(
            id: p.id,
            latitude: p.latitude,
            longitude: p.longitude,
            title: p.name,
          )).toList();

          return Stack(
            children: [
              _mapService.buildMap(
                centerLat: 36.3504,
                centerLng: 127.3845,
                markers: markers,
                onMarkerTapped: (placeId) {
                  // Open bottom sheet or navigate
                },
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.1,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final place = places[index];
                        return ListTile(
                          leading: const Icon(Icons.park),
                          title: Text(place.name),
                          subtitle: Text('${place.type == 'kidscafe' ? '키즈카페' : '공원'} · ${place.priceType == 'free' ? '무료' : '유료'}'),
                          trailing: const Icon(Icons.favorite_border),
                          onTap: () {
                            // Navigate to detail
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('지도 데이터를 불러오는 중 오류가 발생했습니다: $error')),
      ),
    );
  }
}
