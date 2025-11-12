/// Holds compile-time Firebase configuration values exposed via
/// `String.fromEnvironment`. These values are intended to be injected at build
/// time (e.g. via --dart-define) so the app can be configured per environment.
///
/// Factory parameters:
/// - [projectId] - FIREBASE_PROJECT_ID
/// - [messagingSenderId] - FIREBASE_MESSAGING_SENDER_ID
/// - [storageBucket] - FIREBASE_STORAGE_BUCKET
/// - [iosBundleId] - FIREBASE_IOS_BUNDLE_ID
/// - [iosApiKey] - FIREBASE_IOS_APIKEY
/// - [iosApppId] - FIREBASE_IOS_APP_ID
/// - [androidApiKey] - FIREBASE_ANDROID_APIKEY
/// - [androidAppId] - FIREBASE_ANDROID_APP_ID
class FirebaseEnvironment {
  FirebaseEnvironment._();
  static final FirebaseEnvironment _instance = FirebaseEnvironment._();

  static final FirebaseEnvironment instance = _instance;

  String get projectId => const String.fromEnvironment('FIREBASE_PROJECT_ID');
  String get messagingSenderId =>
      const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  String get storageBucket =>
      const String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  String get iosBundleId =>
      const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');
  String get iosApiKey => const String.fromEnvironment('FIREBASE_IOS_APIKEY');
  String get iosApppId => const String.fromEnvironment('FIREBASE_IOS_APP_ID');

  String get androidApiKey =>
      const String.fromEnvironment('FIREBASE_ANDROID_APIKEY');
  String get androidAppId =>
      const String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
}
