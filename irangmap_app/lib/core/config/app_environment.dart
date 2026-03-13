import 'package:flutter/foundation.dart';

class AppEnvironment {
  static const bool mapsPreviewEnabled = bool.fromEnvironment(
    'IRANGMAP_ENABLE_MAPS',
    defaultValue: false,
  );

  static const String androidAdMobAppId = String.fromEnvironment(
    'IRANGMAP_ADMOB_APP_ID_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713',
  );

  static const String iosAdMobAppId = String.fromEnvironment(
    'IRANGMAP_ADMOB_APP_ID_IOS',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511',
  );

  static const String androidBannerAdUnitId = String.fromEnvironment(
    'IRANGMAP_BANNER_AD_UNIT_ID_ANDROID',
    defaultValue: '',
  );

  static const String iosBannerAdUnitId = String.fromEnvironment(
    'IRANGMAP_BANNER_AD_UNIT_ID_IOS',
    defaultValue: '',
  );

  static String get bannerAdUnitId {
    if (kIsWeb) {
      return '';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosBannerAdUnitId;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidBannerAdUnitId;
    }
    return '';
  }

  static const String setupGuide = '''
안드로이드는 `google-services.json`과 Maps/AdMob 키 placeholder를 맞추면 되고,
iOS는 `Runner/GoogleService-Info.plist` 추가 후 `pod install`까지 완료해야 합니다.
지도를 켜려면 native API key 설정 뒤 `--dart-define=IRANGMAP_ENABLE_MAPS=true`로 실행하세요.
배너 광고는 실제 ad unit id를 받은 뒤 별도 dart-define으로 켜는 방식이 가장 안전합니다.
''';
}
