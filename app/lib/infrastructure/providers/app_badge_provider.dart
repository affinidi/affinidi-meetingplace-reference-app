import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:clear_all_notifications/clear_all_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_messaging/push_notification.dart';

/// A service for managing the app’s badge count.
///
/// Uses [AppBadgePlus] for updating badge numbers and
/// [ClearAllNotifications] to clear notifications when needed.
class AppBadgeService {
  AppBadgeService._();

  static final AppBadgeService _instance = AppBadgeService._();
  static final AppBadgeService instance = _instance;

  /// Sets the badge count on the app icon.
  ///
  /// [count] - The number to display on the app badge.
  ///           Use `0` to clear the badge.
  ///
  /// Does nothing if the platform does not support badges.
  Future<void> _setBadge(int count) async {
    if (!await AppBadgePlus.isSupported()) return;

    await AppBadgePlus.updateBadge(count);
  }

  /// Clears the badge count and removes all notifications.
  Future<void> clearBadge() async {
    await _setBadge(0);

    if (kIsWeb) return;
    // ClearAllNotifications does not support macOS.
    if (Platform.isMacOS) return;

    await ClearAllNotifications.clear();
  }

  /// Sets the application badge count based on a Firebase remote message.
  ///
  /// This method processes the incoming [message] and updates the app's badge
  /// indicator accordingly. The badge typically displays the number of
  /// unread notifications or pending items.
  ///
  /// Parameters:
  /// - [message]: The Firebase remote message containing badge information
  ///
  /// Throws:
  /// - May throw platform-specific exceptions if badge setting fails
  ///
  /// Example:
  /// ```dart
  /// await setBadgeFromMessage(remoteMessage);
  /// ```
  Future<void> setBadgeFromMessage(RemoteMessage message) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;
    if (!await AppBadgePlus.isSupported()) return;

    final notification = PushNotification.fromPayload(message.data);
    final pendingCount = notification.data.pendingCount ?? 0;
    await AppBadgePlus.updateBadge(pendingCount);
  }
}

final appBadgeServiceProvider = Provider((ref) => AppBadgeService.instance);
