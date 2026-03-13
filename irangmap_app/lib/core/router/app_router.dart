import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../ui/detail/place_detail_screen.dart';
import '../../ui/home/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/places/:placeId',
        builder: (context, state) {
          final placeId = state.pathParameters['placeId'] ?? '';
          return PlaceDetailScreen(placeId: placeId);
        },
      ),
    ],
  );
});
