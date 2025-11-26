import 'package:firebase_core/firebase_core.dart';

import '../loggers/app_logger/app_logger.dart';
import 'firebase_options.dart';

enum FirebaseInitError {
  configurationError,
  initializationFailed,
}

/// Initializes Firebase and returns an error code if initialization fails.
Future<FirebaseInitError?> initializeFirebase(AppLogger logger) async {
  const logKey = 'Firebase';

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      logger.info('Firebase initialized successfully', name: logKey);
      return null;
    } else {
      logger.warning(
        'Firebase already initialized, skipping initialization',
        name: logKey,
      );
      return null;
    }
  } catch (e, stackTrace) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
      logger.error(
        'Mismatched Firebase configuration, please check your json/plist files',
        error: e,
        stackTrace: stackTrace,
        name: logKey,
      );
      return FirebaseInitError.configurationError;
    } else {
      logger.error(
        'Unexpected error during Firebase initialization',
        error: e,
        stackTrace: stackTrace,
        name: logKey,
      );
      return FirebaseInitError.initializationFailed;
    }
  }
}
