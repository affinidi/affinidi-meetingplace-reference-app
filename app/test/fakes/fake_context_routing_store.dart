import 'package:mpx_flutter_reference_app/application/services/context_routing_service/context_routing_service.dart';

class FakeContextRoutingStore implements ContextRoutingStore {
  final Map<String, Object> _store = {};

  @override
  bool? getBool(String key) => _store[key] as bool?;

  @override
  String? getString(String key) => _store[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async {
    _store[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }
}
