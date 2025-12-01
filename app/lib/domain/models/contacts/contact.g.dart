// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ContactCWProxy {
  Contact channelDid(String? channelDid);

  Contact channelDidSha256(String? channelDidSha256);

  Contact offerLink(String offerLink);

  Contact vCard(VCard vCard);

  Contact type(ContactType type);

  Contact status(ContactStatus status);

  Contact mediatorDid(String mediatorDid);

  Contact origin(ContactOrigin origin);

  Contact category(ContactCategory category);

  Contact otherPartyVCard(VCard? otherPartyVCard);

  Contact displayName(String? displayName);

  Contact badgeUpdateInProgress(bool badgeUpdateInProgress);

  Contact badgeCount(int badgeCount);

  Contact currentMessageSeqNo(int currentMessageSeqNo);

  Contact hasBeenOpened(bool hasBeenOpened);

  Contact unsentMessage(String? unsentMessage);

  Contact lastKeepAliveMessage(DateTime? lastKeepAliveMessage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Contact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Contact(...).copyWith(id: 12, name: "My name")
  /// ````
  Contact call({
    String? channelDid,
    String? channelDidSha256,
    String offerLink,
    VCard vCard,
    ContactType type,
    ContactStatus status,
    String mediatorDid,
    ContactOrigin origin,
    ContactCategory category,
    VCard? otherPartyVCard,
    String? displayName,
    bool badgeUpdateInProgress,
    int badgeCount,
    int currentMessageSeqNo,
    bool hasBeenOpened,
    String? unsentMessage,
    DateTime? lastKeepAliveMessage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfContact.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfContact.copyWith.fieldName(...)`
class _$ContactCWProxyImpl implements _$ContactCWProxy {
  const _$ContactCWProxyImpl(this._value);

  final Contact _value;

  @override
  Contact channelDid(String? channelDid) => this(channelDid: channelDid);

  @override
  Contact channelDidSha256(String? channelDidSha256) =>
      this(channelDidSha256: channelDidSha256);

  @override
  Contact offerLink(String offerLink) => this(offerLink: offerLink);

  @override
  Contact vCard(VCard vCard) => this(vCard: vCard);

  @override
  Contact type(ContactType type) => this(type: type);

  @override
  Contact status(ContactStatus status) => this(status: status);

  @override
  Contact mediatorDid(String mediatorDid) => this(mediatorDid: mediatorDid);

  @override
  Contact origin(ContactOrigin origin) => this(origin: origin);

  @override
  Contact category(ContactCategory category) => this(category: category);

  @override
  Contact otherPartyVCard(VCard? otherPartyVCard) =>
      this(otherPartyVCard: otherPartyVCard);

  @override
  Contact displayName(String? displayName) => this(displayName: displayName);

  @override
  Contact badgeUpdateInProgress(bool badgeUpdateInProgress) =>
      this(badgeUpdateInProgress: badgeUpdateInProgress);

  @override
  Contact badgeCount(int badgeCount) => this(badgeCount: badgeCount);

  @override
  Contact currentMessageSeqNo(int currentMessageSeqNo) =>
      this(currentMessageSeqNo: currentMessageSeqNo);

  @override
  Contact hasBeenOpened(bool hasBeenOpened) =>
      this(hasBeenOpened: hasBeenOpened);

  @override
  Contact unsentMessage(String? unsentMessage) =>
      this(unsentMessage: unsentMessage);

  @override
  Contact lastKeepAliveMessage(DateTime? lastKeepAliveMessage) =>
      this(lastKeepAliveMessage: lastKeepAliveMessage);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Contact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Contact(...).copyWith(id: 12, name: "My name")
  /// ````
  Contact call({
    Object? channelDid = const $CopyWithPlaceholder(),
    Object? channelDidSha256 = const $CopyWithPlaceholder(),
    Object? offerLink = const $CopyWithPlaceholder(),
    Object? vCard = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? mediatorDid = const $CopyWithPlaceholder(),
    Object? origin = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? otherPartyVCard = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? badgeUpdateInProgress = const $CopyWithPlaceholder(),
    Object? badgeCount = const $CopyWithPlaceholder(),
    Object? currentMessageSeqNo = const $CopyWithPlaceholder(),
    Object? hasBeenOpened = const $CopyWithPlaceholder(),
    Object? unsentMessage = const $CopyWithPlaceholder(),
    Object? lastKeepAliveMessage = const $CopyWithPlaceholder(),
  }) {
    return Contact(
      id: _value.id,
      channelDid: channelDid == const $CopyWithPlaceholder()
          ? _value.channelDid
          // ignore: cast_nullable_to_non_nullable
          : channelDid as String?,
      channelDidSha256: channelDidSha256 == const $CopyWithPlaceholder()
          ? _value.channelDidSha256
          // ignore: cast_nullable_to_non_nullable
          : channelDidSha256 as String?,
      offerLink: offerLink == const $CopyWithPlaceholder()
          ? _value.offerLink
          // ignore: cast_nullable_to_non_nullable
          : offerLink as String,
      vCard: vCard == const $CopyWithPlaceholder()
          ? _value.vCard
          // ignore: cast_nullable_to_non_nullable
          : vCard as VCard,
      dateAdded: _value.dateAdded,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as ContactType,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ContactStatus,
      mediatorDid: mediatorDid == const $CopyWithPlaceholder()
          ? _value.mediatorDid
          // ignore: cast_nullable_to_non_nullable
          : mediatorDid as String,
      origin: origin == const $CopyWithPlaceholder()
          ? _value.origin
          // ignore: cast_nullable_to_non_nullable
          : origin as ContactOrigin,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as ContactCategory,
      otherPartyVCard: otherPartyVCard == const $CopyWithPlaceholder()
          ? _value.otherPartyVCard
          // ignore: cast_nullable_to_non_nullable
          : otherPartyVCard as VCard?,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      badgeUpdateInProgress:
          badgeUpdateInProgress == const $CopyWithPlaceholder()
              ? _value.badgeUpdateInProgress
              // ignore: cast_nullable_to_non_nullable
              : badgeUpdateInProgress as bool,
      badgeCount: badgeCount == const $CopyWithPlaceholder()
          ? _value.badgeCount
          // ignore: cast_nullable_to_non_nullable
          : badgeCount as int,
      currentMessageSeqNo: currentMessageSeqNo == const $CopyWithPlaceholder()
          ? _value.currentMessageSeqNo
          // ignore: cast_nullable_to_non_nullable
          : currentMessageSeqNo as int,
      hasBeenOpened: hasBeenOpened == const $CopyWithPlaceholder()
          ? _value.hasBeenOpened
          // ignore: cast_nullable_to_non_nullable
          : hasBeenOpened as bool,
      unsentMessage: unsentMessage == const $CopyWithPlaceholder()
          ? _value.unsentMessage
          // ignore: cast_nullable_to_non_nullable
          : unsentMessage as String?,
      lastKeepAliveMessage: lastKeepAliveMessage == const $CopyWithPlaceholder()
          ? _value.lastKeepAliveMessage
          // ignore: cast_nullable_to_non_nullable
          : lastKeepAliveMessage as DateTime?,
    );
  }
}

extension $ContactCopyWith on Contact {
  /// Returns a callable class that can be used as follows: `instanceOfContact.copyWith(...)` or like so:`instanceOfContact.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContactCWProxy get copyWith => _$ContactCWProxyImpl(this);
}
