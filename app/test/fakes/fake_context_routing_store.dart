import 'dart:convert';

import 'package:mpx_flutter_reference_app/application/services/context_routing_service/context_routing_service.dart';

class FakeContextRoutingStore implements ContextRoutingStore {
  FakeContextRoutingStore({
    bool workContextUploaded = false,
    String? workContextFileName,
    Map<String, AgentContext> contactContexts = const {},
  }) {
    _store['cierge_context_uploaded_work'] = workContextUploaded;
    if (workContextFileName != null) {
      _store['cierge_context_file_name_work'] = workContextFileName;
    }
    if (contactContexts.isNotEmpty) {
      _store['cierge_contact_context_map'] = jsonEncode(
        contactContexts.map((key, value) => MapEntry(key, value.routeKey)),
      );
    }
  }

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
