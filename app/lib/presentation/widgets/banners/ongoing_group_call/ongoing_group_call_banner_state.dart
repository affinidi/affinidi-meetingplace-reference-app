import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show ImageProvider;

/// A single distinct person currently present in an ongoing group call, ready
/// for avatar rendering in the ongoing-call banner.
@immutable
class OngoingGroupCallAvatar {
  const OngoingGroupCallAvatar({required this.id, this.firstName, this.image});

  /// Stable identity for this person (resolved DID when known, otherwise the
  /// Matrix user ID). Used as the widget key and for de-duplication.
  final String id;

  /// The person's given name, when their contact card is known. Drives the
  /// placeholder initial when no avatar image is available.
  final String? firstName;

  /// The avatar image, when the person's contact card is known.
  final ImageProvider<Object>? image;

  @override
  bool operator ==(Object other) =>
      other is OngoingGroupCallAvatar &&
      other.id == id &&
      other.firstName == firstName &&
      other.image == image;

  @override
  int get hashCode => Object.hash(id, firstName, image);
}

/// Presentational data for the ongoing group call banner.
///
/// `null` from the controller means the banner must not be shown (no ongoing
/// call, local user is in a call, or the chat is not a call-capable group).
@immutable
class OngoingGroupCallBannerData {
  OngoingGroupCallBannerData({
    required this.participantCount,
    required List<OngoingGroupCallAvatar> avatars,
  }) : avatars = List.unmodifiable(avatars);

  /// The number of distinct remote people currently in the call. Shown in the
  /// "Ongoing call (n)" label.
  final int participantCount;

  /// The avatars of the remote people currently in the call, in membership
  /// order. The widget decides how many fit before the Join button.
  final List<OngoingGroupCallAvatar> avatars;

  @override
  bool operator ==(Object other) =>
      other is OngoingGroupCallBannerData &&
      other.participantCount == participantCount &&
      _listEquals(other.avatars, avatars);

  @override
  int get hashCode => Object.hash(participantCount, Object.hashAll(avatars));
}

bool _listEquals(
  List<OngoingGroupCallAvatar> a,
  List<OngoingGroupCallAvatar> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
