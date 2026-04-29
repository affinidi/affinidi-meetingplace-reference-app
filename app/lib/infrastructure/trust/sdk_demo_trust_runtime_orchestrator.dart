import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../configuration/environment.dart';

/// Demo-only SDK trust orchestrator that maps MPX lifecycle events to PDP APIs.
///
/// This is intentionally lightweight and local-first:
/// - group create -> create read-only policy
/// - membership approve -> assign viewer role + emit credential reference
/// - protected action -> provide proof payload for SDK trust checks
class SdkDemoTrustRuntimeOrchestrator implements TrustRuntimeOrchestrator {
  SdkDemoTrustRuntimeOrchestrator({
    required Dio dio,
    required Environment environment,
  }) : _dio = dio,
       _env = environment;

  final Dio _dio;
  final Environment _env;

  @override
  Future<TrustGroupContext?> onGroupCreated(Group group) async {
    final baseUrl = _env.trustEnforcerUrl.trim();
    if (baseUrl.isEmpty) return null;

    await _dio.post<Map<String, dynamic>>(
      '$baseUrl/v1/policies',
      data: {'groupId': group.did, 'template': 'read-only'},
      options: Options(headers: {'content-type': 'application/json'}),
    );
    final ownerDid = group.ownerDid;
    if (ownerDid != null && ownerDid.isNotEmpty) {
      await _dio.post<Map<String, dynamic>>(
        '$baseUrl/v1/roles',
        data: {'actorDid': ownerDid, 'groupId': group.did, 'role': 'admin'},
        options: Options(headers: {'content-type': 'application/json'}),
      );
    }

    return TrustGroupContext(
      vtcId: 'vtc:${group.id}',
      trustRegistryId: 'tr:${group.did}',
      communityVtaDid: _env.trustIssuerDid.isNotEmpty
          ? _env.trustIssuerDid
          : null,
    );
  }

  @override
  Future<IssuedMembershipCredential?> onMembershipApproved({
    required Group group,
    required GroupMember member,
  }) async {
    final baseUrl = _env.trustEnforcerUrl.trim();
    if (baseUrl.isEmpty) return null;

    final role = _env.trustRole.isNotEmpty ? _env.trustRole : 'viewer';
    await _dio.post<Map<String, dynamic>>(
      '$baseUrl/v1/roles',
      data: {'actorDid': member.did, 'groupId': group.did, 'role': role},
      options: Options(headers: {'content-type': 'application/json'}),
    );

    return IssuedMembershipCredential(
      credentialId: 'cred:${group.id}:${member.did}',
      issuerDid: _env.trustIssuerDid.isNotEmpty ? _env.trustIssuerDid : null,
      scope: _resolveScope(group),
    );
  }

  @override
  Future<TrustPresentationProof?> buildProofForAction({
    required Group group,
    required String actorDid,
    required String action,
  }) async {
    final proof = _env.trustCredentialProof.isNotEmpty
        ? _env.trustCredentialProof
        : jsonEncode({
            'type': 'demo-proof',
            'action': action,
            'actorDid': actorDid,
            'groupDid': group.did,
            'role': _env.trustRole,
          });

    return TrustPresentationProof(
      credentialProof: proof,
      issuerDid: _env.trustIssuerDid.isNotEmpty ? _env.trustIssuerDid : null,
      scope: _resolveScope(group),
    );
  }

  String _resolveScope(Group group) {
    if (_env.trustScope.isNotEmpty) return _env.trustScope;
    return 'meeting-place/group/${group.did}';
  }
}

