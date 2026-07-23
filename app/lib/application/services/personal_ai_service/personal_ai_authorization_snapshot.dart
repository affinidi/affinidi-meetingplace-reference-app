import 'dart:convert';

import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

class PersonalAiAuthorizationSnapshot {
  factory PersonalAiAuthorizationSnapshot.fromSdk(
    PersonalAgentAuthorizationSnapshot snapshot,
  ) {
    final domainMap = Map<String, dynamic>.from(snapshot.domainMap);

    return PersonalAiAuthorizationSnapshot(
      setupId: snapshot.setupId,
      agentDid: _findString(domainMap, const ['agent_did', 'agentDid']) ?? '',
      aclRole: _findString(domainMap, const ['acl_role', 'aclRole']) ?? '',
      capabilities: _findStringList(domainMap, const ['capabilities']),
      contextScope:
          _findString(domainMap, const ['context_scope', 'contextScope']) ?? '',
      domainId: _findString(domainMap, const ['domain_id', 'domainId']) ?? '',
      provision: _findObject(domainMap, const ['provision']),
      domainMap: domainMap,
      lastUpdated: DateTime.now().toUtc(),
    );
  }

  factory PersonalAiAuthorizationSnapshot.fromJson(Map<String, dynamic> json) {
    final domainMap = json['domain_map'] is Map
        ? Map<String, dynamic>.from(json['domain_map'] as Map)
        : const <String, dynamic>{};

    return PersonalAiAuthorizationSnapshot(
      setupId: (json['setup_id'] as String?) ?? '',
      agentDid:
          _findString(json, const ['agent_did', 'agentDid']) ??
          _findString(domainMap, const ['agent_did', 'agentDid']) ??
          '',
      aclRole:
          _findString(json, const ['acl_role', 'aclRole']) ??
          _findString(domainMap, const ['acl_role', 'aclRole']) ??
          '',
      capabilities: _findStringList(json, const ['capabilities']).isNotEmpty
          ? _findStringList(json, const ['capabilities'])
          : _findStringList(domainMap, const ['capabilities']),
      contextScope:
          _findString(json, const ['context_scope', 'contextScope']) ??
          _findString(domainMap, const ['context_scope', 'contextScope']) ??
          '',
      domainId:
          _findString(json, const ['domain_id', 'domainId']) ??
          _findString(domainMap, const ['domain_id', 'domainId']) ??
          '',
      provision:
          _findObject(json, const ['provision']) ??
          _findObject(domainMap, const ['provision']),
      domainMap: domainMap,
      lastUpdated: _parseTimestamp(json['last_updated'] as String?),
    );
  }

  const PersonalAiAuthorizationSnapshot({
    required this.setupId,
    required this.agentDid,
    required this.aclRole,
    required this.capabilities,
    required this.contextScope,
    required this.domainId,
    this.provision,
    this.domainMap = const <String, dynamic>{},
    this.lastUpdated,
  });

  final String setupId;
  final String agentDid;
  final String aclRole;
  final List<String> capabilities;
  final String contextScope;
  final String domainId;
  final Map<String, dynamic>? provision;
  final Map<String, dynamic> domainMap;
  final DateTime? lastUpdated;

  List<Map<String, dynamic>> get entries =>
      (domainMap['entries'] as List?)
          ?.whereType<Map>()
          .map((entry) => entry.map((key, value) => MapEntry('$key', value)))
          .toList() ??
      const <Map<String, dynamic>>[];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'setup_id': setupId,
      'agent_did': agentDid,
      'acl_role': aclRole,
      'capabilities': capabilities,
      'context_scope': contextScope,
      'domain_id': domainId,
      if (provision != null) 'provision': provision,
      if (domainMap.isNotEmpty) 'domain_map': domainMap,
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
    };
  }

  String toEncodedJson() => jsonEncode(toJson());

  static PersonalAiAuthorizationSnapshot? tryDecode(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return PersonalAiAuthorizationSnapshot.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  static DateTime? _parseTimestamp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String? _findString(Map<String, dynamic> source, List<String> keys) {
    final value = _findValue(source, keys);
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<String> _findStringList(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    final value = _findValue(source, keys);
    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? const <String>[] : <String>[trimmed];
    }
    return const <String>[];
  }

  static Map<String, dynamic>? _findObject(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    final value = _findValue(source, keys);
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) => MapEntry(key.toString(), entryValue),
      );
    }
    return null;
  }

  static Object? _findValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (source.containsKey(key)) {
        final value = source[key];
        if (value != null) {
          return value;
        }
      }
    }

    for (final value in source.values) {
      final nested = _findValueInNode(value, keys);
      if (nested != null) {
        return nested;
      }
    }

    return null;
  }

  static Object? _findValueInNode(Object? node, List<String> keys) {
    if (node is Map<String, dynamic>) {
      return _findValue(node, keys);
    }
    if (node is Map) {
      return _findValue(
        node.map((key, value) => MapEntry(key.toString(), value)),
        keys,
      );
    }
    if (node is Iterable) {
      for (final item in node) {
        final nested = _findValueInNode(item, keys);
        if (nested != null) {
          return nested;
        }
      }
    }
    return null;
  }
}
