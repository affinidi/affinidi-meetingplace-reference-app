import 'dart:convert';

import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

class PersonalAiAuthorizationSnapshot {

  factory PersonalAiAuthorizationSnapshot.fromSdk(
    PersonalAgentAuthorizationSnapshot snapshot,
  ) {
    return PersonalAiAuthorizationSnapshot(
      setupId: snapshot.setupId,
      agentDid: snapshot.agentDid,
      aclRole: snapshot.aclRole,
      capabilities: List<String>.from(snapshot.capabilities),
      contextScope: snapshot.contextScope,
      domainId: snapshot.domainId,
      provision: snapshot.provision,
      lastUpdated: DateTime.now().toUtc(),
    );
  }

  factory PersonalAiAuthorizationSnapshot.fromJson(Map<String, dynamic> json) {
    final capabilities = (json['capabilities'] as List?)
            ?.whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList() ??
        const <String>[];

    return PersonalAiAuthorizationSnapshot(
      setupId: (json['setup_id'] as String?) ?? '',
      agentDid: (json['agent_did'] as String?) ?? '',
      aclRole: (json['acl_role'] as String?) ?? '',
      capabilities: capabilities,
      contextScope: (json['context_scope'] as String?) ?? '',
      domainId: (json['domain_id'] as String?) ?? '',
      provision: json['provision'] is Map
          ? Map<String, dynamic>.from(json['provision'] as Map)
          : null,
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
    this.lastUpdated,
  });

  final String setupId;
  final String agentDid;
  final String aclRole;
  final List<String> capabilities;
  final String contextScope;
  final String domainId;
  final Map<String, dynamic>? provision;
  final DateTime? lastUpdated;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'setup_id': setupId,
      'agent_did': agentDid,
      'acl_role': aclRole,
      'capabilities': capabilities,
      'context_scope': contextScope,
      'domain_id': domainId,
      if (provision != null) 'provision': provision,
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
