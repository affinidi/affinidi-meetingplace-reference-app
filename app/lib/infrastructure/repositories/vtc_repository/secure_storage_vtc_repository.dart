import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/models/vtc/linked_vta.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_group_chat.dart';
import '../../../domain/models/vtc/vtc_left_membership.dart';
import '../../../domain/models/vtc/vtc_vetter_desk.dart';
import '../../../domain/models/vtc/vtc_vetting.dart';
import '../../../domain/repositories/vtc_repository.dart';

/// [VtcRepository] in the platform keystore, because the link carries the
/// manager key and a left membership the member's DID and card: this
/// device only, never synchronised or backed up.
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
  static const _leftMembershipsKey = 'vtc_left_memberships';
  static const _groupChatsKey = 'vtc_group_chats';
  static const _vettingsKey = 'vtc_vettings';
  static const _vetterDesksKey = 'vtc_vetter_desks';

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
  Future<List<VtcLeftMembership>> leftMemberships() async {
    final json = await _storage.read(key: _leftMembershipsKey);
    if (json == null) return const [];
    return [
      for (final left in jsonDecode(json) as List<dynamic>)
        VtcLeftMembership.fromJson(left as Map<String, dynamic>),
    ];
  }

  @override
  Future<void> saveLeftMembership(VtcLeftMembership left) async {
    final others = (await leftMemberships()).where(
      (stored) => stored.key != left.key,
    );
    await _storage.write(
      key: _leftMembershipsKey,
      value: jsonEncode([
        for (final l in [...others, left]) l.toJson(),
      ]),
    );
  }

  @override
  Future<List<VtcGroupChat>> groupChats() async {
    final json = await _storage.read(key: _groupChatsKey);
    if (json == null) return const [];
    return [
      for (final chat in jsonDecode(json) as List<dynamic>)
        VtcGroupChat.fromJson(chat as Map<String, dynamic>),
    ];
  }

  @override
  Future<void> saveGroupChat(VtcGroupChat chat) async {
    final others = (await groupChats()).where(
      (stored) => stored.chatGroupId != chat.chatGroupId,
    );
    await _saveGroupChats([...others, chat]);
  }

  @override
  Future<void> removeGroupChat(String chatGroupId) async {
    await _saveGroupChats([
      ...(await groupChats()).where(
        (stored) => stored.chatGroupId != chatGroupId,
      ),
    ]);
  }

  @override
  Future<VtcVetting?> findVetting(String communityDid) async =>
      (await _vettings())
          .where((vetting) => vetting.communityDid == communityDid)
          .firstOrNull;

  @override
  Future<void> saveVetting(VtcVetting vetting) async {
    await _saveVettings([
      ...(await _vettings()).where(
        (stored) => stored.communityDid != vetting.communityDid,
      ),
      vetting,
    ]);
  }

  @override
  Future<void> removeVetting(String communityDid) async {
    await _saveVettings([
      ...(await _vettings()).where(
        (stored) => stored.communityDid != communityDid,
      ),
    ]);
  }

  @override
  Future<VtcVetterDesk?> findVetterDesk(String communityDid) async =>
      (await _vetterDesks())
          .where((desk) => desk.communityDid == communityDid)
          .firstOrNull;

  @override
  Future<void> saveVetterDesk(VtcVetterDesk desk) async {
    await _saveVetterDesks([
      ...(await _vetterDesks()).where(
        (stored) => stored.communityDid != desk.communityDid,
      ),
      desk,
    ]);
  }

  @override
  Future<void> removeVetterDesk(String communityDid) async {
    await _saveVetterDesks([
      ...(await _vetterDesks()).where(
        (stored) => stored.communityDid != communityDid,
      ),
    ]);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _linkedVtaKey);
    await _storage.delete(key: _communitiesKey);
    await _storage.delete(key: _leftMembershipsKey);
    await _storage.delete(key: _vettingsKey);
    await _storage.delete(key: _vetterDesksKey);
  }

  Future<void> _saveGroupChats(List<VtcGroupChat> chats) => _storage.write(
    key: _groupChatsKey,
    value: jsonEncode([for (final chat in chats) chat.toJson()]),
  );

  Future<List<VtcVetting>> _vettings() async {
    final json = await _storage.read(key: _vettingsKey);
    if (json == null) return const [];
    return [
      for (final vetting in jsonDecode(json) as List<dynamic>)
        VtcVetting.fromJson(vetting as Map<String, dynamic>),
    ];
  }

  Future<void> _saveVettings(List<VtcVetting> vettings) => _storage.write(
    key: _vettingsKey,
    value: jsonEncode([for (final v in vettings) v.toJson()]),
  );

  Future<List<VtcVetterDesk>> _vetterDesks() async {
    final json = await _storage.read(key: _vetterDesksKey);
    if (json == null) return const [];
    return [
      for (final desk in jsonDecode(json) as List<dynamic>)
        VtcVetterDesk.fromJson(desk as Map<String, dynamic>),
    ];
  }

  Future<void> _saveVetterDesks(List<VtcVetterDesk> desks) => _storage.write(
    key: _vetterDesksKey,
    value: jsonEncode([for (final desk in desks) desk.toJson()]),
  );

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
