import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/models/vtc/linked_vta.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/repositories/vtc_repository.dart';

/// [VtcRepository] in the platform keystore, because the link carries the
/// manager key: this device only, never synchronised or backed up.
class SecureStorageVtcRepository implements VtcRepository {
  /// Creates a [SecureStorageVtcRepository].
  SecureStorageVtcRepository([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
              synchronizable: false,
            ),
          );

  static const _linkedVtaKey = 'vtc_linked_vta';
  static const _communitiesKey = 'vtc_communities';

  final FlutterSecureStorage _storage;

  @override
  Future<LinkedVta?> getLinkedVta() async {
    final json = await _storage.read(key: _linkedVtaKey);
    if (json == null) return null;
    return LinkedVta.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> saveLinkedVta(LinkedVta linkedVta) =>
      _storage.write(key: _linkedVtaKey, value: jsonEncode(linkedVta.toJson()));

  @override
  Future<VtcCommunity?> findCommunity(String communityDid) async {
    final communities = await _communities();
    return communities
        .where((community) => community.communityDid == communityDid)
        .firstOrNull;
  }

  @override
  Future<List<VtcCommunity>> communities() => _communities();

  @override
  Future<void> saveCommunity(VtcCommunity community) async {
    await _saveCommunities([
      ...await _othersThan(community.communityDid),
      community,
    ]);
  }

  @override
  Future<void> removeCommunity(String communityDid) async {
    await _saveCommunities(await _othersThan(communityDid));
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _linkedVtaKey);
    await _storage.delete(key: _communitiesKey);
  }

  Future<List<VtcCommunity>> _othersThan(String communityDid) async => [
    ...(await _communities()).where(
      (stored) => stored.communityDid != communityDid,
    ),
  ];

  Future<void> _saveCommunities(List<VtcCommunity> communities) =>
      _storage.write(
        key: _communitiesKey,
        value: jsonEncode([for (final c in communities) c.toJson()]),
      );

  Future<List<VtcCommunity>> _communities() async {
    final json = await _storage.read(key: _communitiesKey);
    if (json == null) return const [];
    return [
      for (final community in jsonDecode(json) as List<dynamic>)
        VtcCommunity.fromJson(community as Map<String, dynamic>),
    ];
  }
}
