import 'package:shared_preferences/shared_preferences.dart';

import '../../application/services/context_routing_service/context_routing_service.dart';

class SharedPreferencesContextRoutingStore implements ContextRoutingStore {
  const SharedPreferencesContextRoutingStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
}
