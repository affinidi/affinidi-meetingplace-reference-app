import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/linked_vta.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_group_chat.dart';
import '../../../domain/models/vtc/vtc_left_membership.dart';
import '../../../domain/models/vtc/vtc_member_link.dart';
import '../../../domain/models/vtc/vtc_vetter_desk.dart';
import '../../../domain/models/vtc/vtc_vetting.dart';
import '../../../domain/repositories/vtc_repository.dart';

/// [VtcRepository] in the platform keystore, because the link carries the
/// manager key, and a left membership or a kept membership card the
/// member's DID and card: this device only, never synchronised or backed up.
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
  static const _managerSeedsKey = 'vtc_manager_seeds';
  static const _communitiesKey = 'vtc_communities';
  static const _leftMembershipsKey = 'vtc_left_memberships';
  static const _membershipCardsKey = 'vtc_membership_cards';
  static const _groupChatsKey = 'vtc_group_chats';
  static const _memberLinksKey = 'vtc_member_links';
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
  Future<Uint8List?> findManagerSeed(String vtaDid) async {
    final seed = (await _managerSeeds())[vtaDid];
    return seed == null ? null : Uint8List.fromList(base64Url.decode(seed));
  }

  @override
  Future<void> saveManagerSeed(String vtaDid, Uint8List seed) async {
    final seeds = {...await _managerSeeds(), vtaDid: base64Url.encode(seed)};
    await _storage.write(key: _managerSeedsKey, value: jsonEncode(seeds));
  }

  Future<Map<String, String>> _managerSeeds() async {
    final json = await _storage.read(key: _managerSeedsKey);
    if (json == null) return const {};
    return (jsonDecode(json) as Map<String, dynamic>).cast<String, String>();
  }

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
  Future<List<StoredCredential>> membershipCards() async {
    final json = await _storage.read(key: _membershipCardsKey);
    if (json == null) return const [];
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return const [];
    }
    // A card kept in another shape is left out: the next read from the VTA
    // replaces them all.
    return [
      if (decoded is List<dynamic>)
        for (final card in decoded) ?_storedCredentialFromJson(card),
    ];
  }

  @override
  Future<void> saveMembershipCards(List<StoredCredential> cards) =>
      _storage.write(
        key: _membershipCardsKey,
        value: jsonEncode([
          for (final card in cards) _storedCredentialToJson(card),
        ]),
      );

  static Map<String, dynamic> _storedCredentialToJson(StoredCredential card) {
    final record = card.record;
    return {
      'id': record.id,
      'types': record.types,
      'issuerDid': ?record.issuerDid,
      'validFrom': ?record.validFrom?.toIso8601String(),
      'validUntil': ?record.validUntil?.toIso8601String(),
      'purpose': ?record.purpose,
      'status': ?record.status,
      'credential': card.credential,
    };
  }

  static StoredCredential? _storedCredentialFromJson(Object? json) =>
      switch (json) {
        {
          'id': final String id,
          'types': final List<dynamic> types,
          'credential': final Map<String, dynamic> credential,
        } =>
          StoredCredential(
            record: HeldCredential(
              id: id,
              types: List.unmodifiable(types.whereType<String>()),
              issuerDid: _stringOf(json['issuerDid']),
              validFrom: DateTime.tryParse('${json['validFrom']}'),
              validUntil: DateTime.tryParse('${json['validUntil']}'),
              purpose: _stringOf(json['purpose']),
              status: _stringOf(json['status']),
            ),
            credential: credential,
          ),
        _ => null,
      };

  static String? _stringOf(Object? value) => value is String ? value : null;

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
  Future<List<VtcMemberLink>> memberLinks({String? channelDid}) async {
    final json = await _storage.read(key: _memberLinksKey);
    if (json == null) return const [];
    final links = [
      for (final link in jsonDecode(json) as List<dynamic>)
        VtcMemberLink.fromJson(link as Map<String, dynamic>),
    ];
    if (channelDid == null) return links;
    return [...links.where((link) => link.channelDid == channelDid)];
  }

  @override
  Future<void> saveMemberLink(VtcMemberLink link) async {
    final others = (await memberLinks()).where(
      (stored) =>
          stored.communityDid != link.communityDid ||
          stored.channelDid != link.channelDid,
    );
    await _saveMemberLinks([...others, link]);
  }

  @override
  Future<void> removeMemberLinks(String communityDid) async {
    await _saveMemberLinks([
      ...(await memberLinks()).where(
        (stored) => stored.communityDid != communityDid,
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
    await _storage.delete(key: _membershipCardsKey);
    await _storage.delete(key: _vettingsKey);
    await _storage.delete(key: _vetterDesksKey);
    await _storage.delete(key: _memberLinksKey);
  }

  Future<void> _saveMemberLinks(List<VtcMemberLink> links) => _storage.write(
    key: _memberLinksKey,
    value: jsonEncode([for (final link in links) link.toJson()]),
  );

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
