import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Initialization
  await Firebase.initializeApp();

  // AdMob Initialization with Child-Directed Treatment
  await MobileAds.instance.initialize();
  RequestConfiguration requestConfiguration = RequestConfiguration(
    tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
    tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
    maxAdContentRating: MaxAdContentRating.g,
  );
  await MobileAds.instance.updateRequestConfiguration(requestConfiguration);

  runApp(const ProviderScope(child: IrangMapApp()));
}

class IrangMapApp extends ConsumerWidget {
  const IrangMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: '아이랑맵',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
