import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification.freezed.dart';

enum PushNotificationType {
  channelActivity('ChannelActivity'),
  offerFinalised('OfferFinalised'),
  invitationAccept('InvitationAccept'),
  invitationGroupAccept('InvitationGroupAccept'),
  invitationOutreach('InvitationOutreach'),
  groupMembershipFinalised('GroupMembershipFinalised'),
  other('Other');

  const PushNotificationType(this.value);

  factory PushNotificationType.fromValue(String value) {
    return PushNotificationType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PushNotificationType.other,
    );
  }

  final String value;
}

/// Data payload of a push notification.
///
/// Contains additional information like [pendingCount].
@freezed
abstract class PushNotificationData with _$PushNotificationData {
  const factory PushNotificationData({
    int? pendingCount,
  }) = _PushNotificationData;

  /// Creates a [PushNotificationData] from a JSON map.
  ///
  /// - Safely parses `pendingCount` as an integer if possible.
  factory PushNotificationData.fromJson(Map<String, dynamic> json) {
    return PushNotificationData(
      pendingCount: json['pendingCount'] is int
          ? json['pendingCount'] as int
          : int.tryParse(json['pendingCount']?.toString() ?? ''),
    );
  }
}

/// Represents a push notification with a [type] and [data].
@freezed
abstract class PushNotification with _$PushNotification {
  const factory PushNotification({
    @Default(PushNotificationType.other) PushNotificationType type,
    @Default(PushNotificationData()) PushNotificationData data,
  }) = _PushNotification;

  /// Creates a [PushNotification] from raw payload data.
  ///
  /// - Parses the `affinidiInfo` field (string or map).
  /// - Determines the [type] from the payload.
  /// - Extracts the [data] as [PushNotificationData].
  ///
  /// Throws an [Exception] if `affinidiInfo` is not a valid map.
  factory PushNotification.fromPayload(Map<String, dynamic> messageData) {
    dynamic affinidiInfo = messageData['affinidiInfo'];
    if (affinidiInfo is String) {
      affinidiInfo = jsonDecode(affinidiInfo) as Map<String, dynamic>;
    }
    if (affinidiInfo is! Map<String, dynamic>) {
      throw Exception('affinidiInfo is not a Map<String, dynamic>');
    }

    final typeStr = affinidiInfo['type'] as String? ?? '';
    final type = PushNotificationType.fromValue(typeStr);

    final dataJson = affinidiInfo['data'] as Map<String, dynamic>? ?? {};
    final data = PushNotificationData.fromJson(dataJson);

    return PushNotification(type: type, data: data);
  }
}
