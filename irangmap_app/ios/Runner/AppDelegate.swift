import FirebaseCore
import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if FirebaseApp.app() == nil {
      if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
        FirebaseApp.configure()
      } else {
        NSLog("[IrangMap] GoogleService-Info.plist not found. Firebase will stay disabled for this launch.")
      }
    }

    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      let trimmedApiKey = mapsApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmedApiKey.isEmpty {
        GMSServices.provideAPIKey(trimmedApiKey)
      } else {
        NSLog("[IrangMap] GMSApiKey is empty. Google Maps native SDK will stay disabled.")
      }
    } else {
      NSLog("[IrangMap] GMSApiKey is missing. Google Maps native SDK will stay disabled.")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
