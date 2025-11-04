import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

import '../configuration/environment.dart';
import '../loggers/app_logger/app_logger.dart';
import '../providers/app_badge_provider.dart';
import '../providers/app_logger_provider.dart';
import '../providers/push_notification_messaging_provider.dart';
import '../secure_storage/secure_storage.dart';
import 'push_notification_messaging.dart';

part 'push_notifications_handler.g.dart';

/// A Riverpod provider class that handles push notifications lifecycle,
/// device token updates, and notification streams.
@Riverpod(keepAlive: true)
class PushNotificationsHandler extends _$PushNotificationsHandler {
  PushNotificationsHandler() : super();

  /// Emits new push device tokens.
  final _receivedDeviceTokenController = StreamController<String>.broadcast();
  Stream<String> get onReceivedDeviceToken =>
      _receivedDeviceTokenController.stream;

  final _failedToGetDeviceTokenController = StreamController<void>.broadcast();
  Stream<void> get onFailedToGetDeviceToken =>
      _failedToGetDeviceTokenController.stream;

  /// Emits events whenever notifications are processed internally.
  final _pushNotificationReceivedController =
      StreamController<void>.broadcast();
  Stream<void> get onPushNotificationReceived =>
      _pushNotificationReceivedController.stream;

  final _requiredPermissions = [
    _Permissions.alert,
    _Permissions.badge,
    _Permissions.sound
  ];

  late final PushNotificationMessaging _pushNotificationMessaging;
  late final AppLogger _logger = ref.read(appLoggerProvider);
  static const _logKey = 'PSHNTFYSVC';
  String? _lastSavedPushNotificationToken;
  late final _handlingTokenLock = Lock();

  @override
  Future<void> build() async {
    final secureStorage = await ref.read(secureStorageProvider.future);
    final pushNotificationToken =
        await secureStorage.getPushNotificationToken();
    if (pushNotificationToken != null) {
      _logger.info(
        'Existing PushToken found during initialization: '
        '$pushNotificationToken',
        name: _logKey,
      );
      await _handlePushNotificationToken(pushNotificationToken);
    }

    _pushNotificationMessaging =
        await ref.read(pushNotificationMessagingProvider.future);

    // Subscribe to push notification token changes
    _pushNotificationMessaging.onTokenRefresh
        .listen((String newDeviceToken) async {
      _logger.info(
        'Device token refreshed: '
        '$newDeviceToken',
        name: _logKey,
      );
      _logger.info(
        'Initiating device re-registration with new token',
        name: _logKey,
      );
      await _handlePushNotificationToken(newDeviceToken);
    });

    // Subscribe to new messages
    _pushNotificationMessaging.onMessage.listen((RemoteMessage message) async {
      _logger.info(
        'Push notification received in foreground',
        name: _logKey,
      );
      _logger.debug(
        'Push notification data: ${message.data}',
        name: _logKey,
      );

      await ref.read(appBadgeServiceProvider).setBadgeFromMessage(message);

      _pushNotificationReceivedController.add(null);
    });

    unawaited(
      Future(
        () async {
          _requestPermissions();
          await getToken();
          await _setupInteractedMessage();
        },
      ),
    );
  }

  Future<void> getToken() async {
    await _requestIOSAPNSToken();
    await _pushNotificationMessaging.getToken().then(
        (String? newDeviceToken) async {
      _logger.info(
        'Initial PushToken: ${newDeviceToken ?? 'empty'}',
        name: _logKey,
      );

      if (newDeviceToken == null) {
        _logger.warning(
          'No device token received during initialization',
          name: _logKey,
        );
        return;
      }

      _logger.info(
        'Device token received successfully, initiating registration',
        name: _logKey,
      );
      await _handlePushNotificationToken(newDeviceToken);
    }, onError: (dynamic error) {
      _failedToGetDeviceTokenController.add(null);

      if (_lastSavedPushNotificationToken != null) {
        _logger.warning(
          '''Unable to get device token, continuing with an FCM token from previous sessions''',
          name: _logKey,
        );
      } else {
        _logger.error(
          'Error while getting PushToken',
          error: error,
          name: _logKey,
        );
      }
    });
  }

  Future<void> _handlePushNotificationToken(
      String pushNotificationToken) async {
    await _handlingTokenLock.synchronized(() async {
      if (_lastSavedPushNotificationToken != null &&
          _lastSavedPushNotificationToken != pushNotificationToken) {
        _logger.warning(
          'Push notification token has changed from '
          '$_lastSavedPushNotificationToken to $pushNotificationToken',
          name: _logKey,
        );
      }
      if (_lastSavedPushNotificationToken != pushNotificationToken) {
        final secureStorage = await ref.read(secureStorageProvider.future);
        await secureStorage.savePushNotificationToken(pushNotificationToken);
        _lastSavedPushNotificationToken = pushNotificationToken;
      }
      _receivedDeviceTokenController.add(pushNotificationToken);
    });
  }

  void _requestPermissions() {
    unawaited(_pushNotificationMessaging
        .requestPermission(
      alert: _hasPermission(_Permissions.alert),
      badge: _hasPermission(_Permissions.badge),
      sound: _hasPermission(_Permissions.sound),
    )
        .then((settings) {
      _logger.info('User granted permission: ${settings.authorizationStatus}',
          name: _logKey);
      _enableiOSForegroundNotifications();
    }));
  }

  Future<void> _requestIOSAPNSToken() async {
    if (kIsWeb) return;
    if (!Platform.isIOS && !Platform.isMacOS) return;

    final maxAttempts = 5;
    var attempt = 0;
    var delayMs = 500;

    while (attempt < maxAttempts) {
      _logger.info('getAPNSToken attempt $attempt', name: _logKey);

      // For apple platforms, ensure the APNS token is available
      // before making any FCM plugin API calls
      final token = await _pushNotificationMessaging.getAPNSToken();

      if (token != null) {
        return;
      }

      attempt++;
      if (attempt < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // exponential backoff
      } else {
        _logger.error(
          'Unable to find apnsToken after $attempt attempts',
          name: _logKey,
        );
      }
    }
  }

  Future<void> _enableiOSForegroundNotifications() async {
    if (kIsWeb) return;
    if (!Platform.isIOS && !Platform.isMacOS) return;

    final isForegroundNotificationsEnabled =
        ref.read(environmentProvider).isForegroundNotificationsEnabled;
    await _pushNotificationMessaging
        .setForegroundNotificationPresentationOptions(
      alert: isForegroundNotificationsEnabled &&
          _hasPermission(_Permissions.alert),
      badge: isForegroundNotificationsEnabled &&
          _hasPermission(_Permissions.badge),
      sound: isForegroundNotificationsEnabled &&
          _hasPermission(_Permissions.sound),
    );
  }

  /// Sets up handling for push notifications opened
  /// when the app is in background or terminated state.
  Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    var initialMessage = await _pushNotificationMessaging.getInitialMessage();

    if (initialMessage != null) {
      await _handleOpeningNotification(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    _pushNotificationMessaging.onMessageOpenedApp
        .listen(_handleOpeningNotification);
  }

  /// Handles notifications opened by the user.
  Future<void> _handleOpeningNotification(RemoteMessage message) async {
    _logger.info(
      'Opened a notification with message $message',
      name: _logKey,
    );
    _pushNotificationReceivedController.add(null);
  }

  /// Checks if the given [_Permissions] is in the required list.
  bool _hasPermission(_Permissions permission) =>
      _requiredPermissions.contains(permission);
}

enum _Permissions {
  alert,
  badge,
  sound,
  ;
}
