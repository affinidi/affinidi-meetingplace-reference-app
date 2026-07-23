import 'dart:convert';

import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

class PersonalAiAuthorizationSnapshot {
  factory PersonalAiAuthorizationSnapshot.fromSdk(
    PersonalAgentAuthorizationSnapshot snapshot,
  ) {
    return PersonalAiAuthorizationSnapshot(
      setupId: snapshot.setupId,
      domainMap: Map<String, dynamic>.from(snapshot.domainMap),
      lastUpdated: DateTime.now().toUtc(),
    );
  }

  factory PersonalAiAuthorizationSnapshot.fromJson(Map<String, dynamic> json) {
    return PersonalAiAuthorizationSnapshot(
      setupId: (json['setup_id'] as String?) ?? '',
      domainMap: json['domain_map'] is Map
          ? Map<String, dynamic>.from(json['domain_map'] as Map)
          : <String, dynamic>{},
      lastUpdated: _parseTimestamp(json['last_updated'] as String?),
    );
  }
  const PersonalAiAuthorizationSnapshot({
    required this.setupId,
    required this.domainMap,
    this.lastUpdated,
  });

  final String setupId;
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
      'domain_map': domainMap,
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
}
