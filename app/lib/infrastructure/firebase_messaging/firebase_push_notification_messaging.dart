// ignore_for_file: unreachable_from_main

import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../loggers/app_logger/app_logger.dart';
import 'push_notification.dart';
import 'push_notification_messaging.dart';

/// Background handler for Firebase push notifications.
///
/// Called when a message is received while the app is in the background.
/// Logs the message and updates the app badge count for Android devices.
/// iOS badge is handled automatically by the OS using the native APNS
/// badge field.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.instance.info(
    'Handling a background message: ${message.messageId}',
    name: 'firebaseMessagingBackgroundHandler',
  );

  if (Platform.isAndroid) {
    final notification = PushNotification.fromPayload(message.data);
    final pendingCount = notification.data.pendingCount ?? 0;

    if (await AppBadgePlus.isSupported()) {
      await AppBadgePlus.updateBadge(pendingCount);
    }
  }
}

class FirebasePushNotificationMessaging implements PushNotificationMessaging {
  FirebasePushNotificationMessaging(this._instance);

  final FirebaseMessaging _instance;

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) =>
      _instance.requestPermission(
        alert: alert,
        announcement: announcement,
        badge: badge,
        carPlay: carPlay,
        criticalAlert: criticalAlert,
        provisional: provisional,
        sound: sound,
        providesAppNotificationSettings: providesAppNotificationSettings,
      );

  @override
  void setBackgroundHandler(BackgroundMessageHandler handler) {
    FirebaseMessaging.onBackgroundMessage(handler);
  }

  @override
  Future<String?> getAPNSToken() => _instance.getAPNSToken();

  @override
  Future<RemoteMessage?> getInitialMessage() => _instance.getInitialMessage();

  @override
  Future<String?> getToken({
    String? vapidKey,
  }) =>
      _instance.getToken(
        vapidKey: vapidKey,
      );

  @override
  Stream<String> get onTokenRefresh => _instance.onTokenRefresh;

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) =>
      _instance.setForegroundNotificationPresentationOptions(
        alert: alert,
        badge: badge,
        sound: sound,
      );

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;
}
