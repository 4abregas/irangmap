# IrangMap Project Status

## 현재까지 작업한 내용

### 1. Flutter 앱 안정화

- 앱 시작 시 Firebase/AdMob 초기화를 안전하게 감싸서, 설정이 덜 된 환경에서도 앱이 바로 종료되지 않도록 변경
- 홈 화면과 상세 화면 모두 bootstrap 상태를 확인한 뒤 동작하도록 보강
- Google Maps는 native 키가 준비된 뒤 `IRANGMAP_ENABLE_MAPS=true`일 때만 켜지도록 구성

관련 파일:

- `irangmap_app/lib/main.dart`
- `irangmap_app/lib/core/bootstrap/app_bootstrap.dart`
- `irangmap_app/lib/core/config/app_environment.dart`
- `irangmap_app/lib/ui/detail/place_detail_screen.dart`

### 2. Android 환경 정리

- `AndroidManifest.xml`에 인터넷/네트워크 권한 추가
- Google Maps / AdMob 메타데이터 placeholder 방식으로 연결
- `build.gradle.kts`에서 local properties와 gradle properties를 읽도록 변경
- `key.properties`가 있으면 release 서명, 없으면 debug 서명으로 fallback 하도록 구성

관련 파일:

- `irangmap_app/android/app/src/main/AndroidManifest.xml`
- `irangmap_app/android/app/build.gradle.kts`
- `irangmap_app/android/gradle.properties`
- `irangmap_app/.gitignore`

### 3. iOS 환경 정리

- 누락되어 있던 `Podfile` 추가
- `AppConfig.xcconfig`로 Maps/AdMob 키를 관리하도록 구성
- `Info.plist`에 앱 이름, AdMob App ID, Maps key, embedded views, 위치 설명 추가
- `AppDelegate.swift`에서 Google Maps API key를 읽어 등록하도록 처리
- `GoogleService-Info.plist`는 로컬에서 넣을 수 있게 `.gitignore`에 추가

관련 파일:

- `irangmap_app/ios/Podfile`
- `irangmap_app/ios/Flutter/AppConfig.xcconfig`
- `irangmap_app/ios/Flutter/Debug.xcconfig`
- `irangmap_app/ios/Flutter/Release.xcconfig`
- `irangmap_app/ios/Runner/Info.plist`
- `irangmap_app/ios/Runner/AppDelegate.swift`
- `irangmap_app/ios/.gitignore`

### 4. UI/UX 및 대시보드 리디자인

- 홈 화면을 단순 지도+시트 구조에서 대시보드형으로 재구성
- 검색, 빠른 필터, 운영 지표 카드, 추천 카드, 장소 리스트 중심 UX로 변경
- 지도 미준비 시에는 안내 카드가 보이도록 처리
- 앱 전체 톤을 따뜻하고 정돈된 스타일로 맞춘 커스텀 테마 적용

관련 파일:

- `irangmap_app/lib/core/theme/app_theme.dart`
- `irangmap_app/lib/ui/home/home_screen.dart`
- `irangmap_app/lib/core/map/google_map_service_impl.dart`

### 5. 관리자 페이지 기본 정리

- Next.js 관리자 첫 화면을 템플릿에서 IrangMap 운영 대시보드형 랜딩으로 변경
- `app/`와 `src/app/`가 섞여 있던 구조를 shim으로 정리

관련 파일:

- `irangmap_admin/src/app/page.tsx`
- `irangmap_admin/src/app/layout.tsx`
- `irangmap_admin/src/app/globals.css`
- `irangmap_admin/app/page.tsx`
- `irangmap_admin/app/layout.tsx`

## 중요한 내용

- iOS는 구조는 잡아두었지만, 실제 `GoogleService-Info.plist`는 Firebase Console에서 받은 진짜 파일이 반드시 필요합니다.
- Maps는 native API key 없이는 안정적으로 켜지지 않으므로, 기본값은 안전 모드입니다.
- Android release 서명은 `android/key.properties`와 keystore가 있어야 운영용으로 마무리됩니다.
- 현재 환경에서는 `flutter`/`dart`가 없어 실제 빌드, `flutter pub get`, `pod install`, `flutter analyze`는 수행하지 못했습니다.

## 큰 방향

1. 먼저 iOS 실행 가능 상태를 실제 기기/시뮬레이터 기준으로 확인
2. 그다음 Android/iOS 공통 환경값을 정리해 운영 기준을 하나로 통일
3. 이후 사용자 대시보드 필터/추천 로직을 실제 데이터 기준으로 고도화
4. 마지막으로 관리자 페이지를 Firestore 검수 패널로 연결

## 다음에 할 일 우선순위

1. Flutter SDK 설치 후 `flutter pub get`
2. iOS용 `GoogleService-Info.plist` 추가
3. iOS `pod install`
4. Android/iOS Maps 및 AdMob 실제 키 입력
5. Android/iOS 각각 실제 실행 및 에러 로그 점검
6. 지도 활성화 (`IRANGMAP_ENABLE_MAPS=true`) 후 동작 확인
7. 홈 화면 필터를 Firestore 데이터 구조와 더 정교하게 연결
8. 관리자 검수 화면을 실데이터 기반으로 연결

## 내가 할 수 있는 것

- 코드 수정 및 구조 정리
- Android/iOS/웹 설정 파일 구성
- UI/UX 개선과 대시보드 설계
- 문서화, 체크리스트, 운영 가이드 정리
- 에러 로그를 보고 원인 추적 및 수정 제안
- 커밋/푸시/브랜치 관리

## 내가 할 수 없는 것

- Firebase Console, Apple Developer, Google Cloud Console에서 직접 앱 등록하거나 키를 발급하는 일
- 실제 iOS 서명 인증서/프로비저닝 프로파일 생성
- 사용자 계정 권한이 필요한 외부 콘솔 설정 확정
- 현재 머신에 없는 Flutter SDK 없이 실제 `flutter` 빌드 실행

## 사용자가 제공해주면 좋은 것

- iOS Firebase 앱 등록 후 받은 `GoogleService-Info.plist`
- Android/iOS Google Maps API key
- Android/iOS AdMob App ID
- Android 운영 배포용 keystore와 `key.properties`
- Apple Developer Team / Bundle ID 확정값
- 실제로 보고 있는 에러 로그 또는 캡처

## 에이전트/스킬 메모

- 저장소 내 `.agents/frontend-developer.md`를 확인했고, 프론트엔드 작업 원칙은 참고했습니다.
- 다만 그 문서가 요구하는 `context-manager`는 현재 이 환경에 없어서, 실제 사용 가능한 범위 내에서 수동으로 컨텍스트를 수집해 작업했습니다.
