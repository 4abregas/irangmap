import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppBootstrapState {
  final bool firebaseReady;
  final bool adsReady;
  final String? firebaseMessage;
  final String? adsMessage;

  const AppBootstrapState({
    required this.firebaseReady,
    required this.adsReady,
    this.firebaseMessage,
    this.adsMessage,
  });

  bool get canLoadRemoteData => firebaseReady;
}

final appBootstrapProvider = FutureProvider<AppBootstrapState>((ref) async {
  var firebaseReady = false;
  var adsReady = false;
  String? firebaseMessage;
  String? adsMessage;

  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (error) {
    firebaseMessage = _friendlyMessage(
      error,
      fallback:
          'Firebase 초기화에 실패했습니다. iOS는 GoogleService-Info.plist, Android는 google-services.json과 앱 패키지명을 확인해 주세요.',
    );
  }

  try {
    await MobileAds.instance.initialize();
    const requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      maxAdContentRating: MaxAdContentRating.g,
    );
    await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
    adsReady = true;
  } catch (error) {
    adsMessage = _friendlyMessage(
      error,
      fallback: 'AdMob 초기화에 실패했습니다. 앱은 계속 동작하지만 광고 영역은 비활성화됩니다.',
    );
  }

  return AppBootstrapState(
    firebaseReady: firebaseReady,
    adsReady: adsReady,
    firebaseMessage: firebaseMessage,
    adsMessage: adsMessage,
  );
});

String _friendlyMessage(Object error, {required String fallback}) {
  final message = error.toString().trim();
  if (message.isEmpty) {
    return fallback;
  }
  return '$fallback\n$message';
}
