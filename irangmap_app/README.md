# irangmap_app

아이와 함께 갈 수 있는 장소를 빠르게 찾는 Flutter 앱입니다. 현재 구조는 `Firebase + Firestore`, `Google Maps`, `AdMob` 기준으로 맞춰져 있으며, 설정이 덜 된 환경에서도 앱이 바로 죽지 않도록 안전 모드 부트스트랩을 넣어 두었습니다.

## 실행 전 준비

### Android

1. `android/app/google-services.json`이 현재 패키지명 `com.irangmap.app`와 일치하는지 확인합니다.
2. `android/local.properties` 또는 `~/.gradle/gradle.properties`에 아래 값을 넣습니다.

```properties
IRANGMAP_GOOGLE_MAPS_API_KEY_ANDROID=your-android-maps-key
IRANGMAP_ADMOB_APP_ID_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

3. 운영 배포용 서명이 필요하면 `android/key.properties`를 추가합니다.

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

### iOS

1. Firebase Console에서 iOS 앱을 등록하고 `GoogleService-Info.plist`를 받아 `ios/Runner/GoogleService-Info.plist`에 둡니다.
2. `ios/Flutter/AppConfig.xcconfig`의 값을 실제 키로 교체합니다.

```xcconfig
IRANGMAP_GOOGLE_MAPS_API_KEY_IOS = your-ios-maps-key
IRANGMAP_ADMOB_APP_ID_IOS = ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

3. Flutter SDK가 설치된 상태에서 아래를 실행합니다.

```bash
flutter pub get
cd ios
pod install
cd ..
```

## 지도 미리보기 켜기

지도는 native API key가 모두 들어간 뒤 아래 플래그로 활성화하도록 되어 있습니다.

```bash
flutter run --dart-define=IRANGMAP_ENABLE_MAPS=true
```

키가 빠져 있으면 홈 화면에서 지도 대신 설정 안내 카드가 표시됩니다.

## 현재 안정화 포인트

- Firebase/AdMob 초기화 실패 시 앱이 종료되지 않고 안내 화면으로 전환됩니다.
- Android는 Maps/AdMob 키를 placeholder로 주입받습니다.
- iOS는 Podfile, xcconfig, Info.plist, AppDelegate까지 Maps/AdMob 연동 구조를 갖췄습니다.
- 홈 화면은 검색, 필터, 추천 카드, 운영 지표 중심의 대시보드 UX로 정리되어 있습니다.
