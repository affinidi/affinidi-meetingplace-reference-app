import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:clear_all_notifications/clear_all_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A service for managing the app’s badge count.
///
/// Uses [AppBadgePlus] for updating badge numbers and
/// [ClearAllNotifications] to clear notifications when needed.
class AppBadgeService {
  /// Sets the badge count on the app icon.
  ///
  /// [count] - The number to display on the app badge.
  ///           Use `0` to clear the badge.
  ///
  /// Does nothing if the platform does not support badges.
  Future<void> setBadge(int count) async {
    if (await AppBadgePlus.isSupported()) {
      await AppBadgePlus.updateBadge(count);
    }
  }

  /// Clears the badge count and removes all notifications.
  Future<void> clearBadge() async {
    await setBadge(0);

    if (kIsWeb) return;
    // ClearAllNotifications does not support macOS.
    if (Platform.isMacOS) return;

    await ClearAllNotifications.clear();
  }
}

final appBadgeServiceProvider = Provider((ref) => AppBadgeService());
