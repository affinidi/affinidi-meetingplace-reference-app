import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enumeration of keys used for storing and retrieving values from
/// SharedPreferences.
///
/// This enum provides a centralized way to manage SharedPreferences keys,
/// ensuring consistency across the application and reducing the risk of
/// typos when accessing stored preferences.
enum SharedPreferencesKeys {
  alreadyInstalled,
  alreadyOnboarded;
}

/// Provider that supplies the global [SharedPreferences] instance.
///
/// Used for storing and retrieving simple key-value pairs across the app
/// lifecycle.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Make sure to override this provider');
}, name: 'sharedPreferencesProvider');
