import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mpx_flutter_reference_app/infrastructure/firebase_messaging/push_notification_messaging.dart';

class FakePushNotificationMessaging implements PushNotificationMessaging {
  FakePushNotificationMessaging({
    String? tokenToReturn,
    RemoteMessage? initialMessageToReturn,
    int attemptsToFailGettingToken = 0,
    int attemptsToFailGettingApnsToken = 0,
    String? apnsTokenToReturn,
  }) : _initialMessageToReturn = initialMessageToReturn,
       _tokenToReturn = tokenToReturn,
       _attemptsToFailGettingToken = attemptsToFailGettingToken,
       _attemptsToFailGettingApnsToken = attemptsToFailGettingApnsToken;

  final String? _tokenToReturn;
  final RemoteMessage? _initialMessageToReturn;
  final int _attemptsToFailGettingToken;
  final int _attemptsToFailGettingApnsToken;

  int _currentAttemptsToGetToken = 0;
  int _currentAttemptsToGetApnsToken = 0;
  bool _permissionsRequested = false;
  bool get permissionsRequested => _permissionsRequested;

  bool _foregroundPresentationAlertRequested = false;
  bool get foregroundPresentationAlertRequested =>
      _foregroundPresentationAlertRequested;
  bool _foregroundPresentationBadgeRequested = false;
  bool get foregroundPresentationBadgeRequested =>
      _foregroundPresentationBadgeRequested;
  bool _foregroundPresentationSoundRequested = false;
  bool get foregroundPresentationSoundRequested =>
      _foregroundPresentationSoundRequested;

  final _deviceTokenRefreshController = StreamController<String>.broadcast();
  @override
  Stream<String> get onTokenRefresh => _deviceTokenRefreshController.stream;

  late BackgroundMessageHandler backgroundMessageHandler;

  @override
  Future<String?> getAPNSToken() async {
    if (_currentAttemptsToGetApnsToken < _attemptsToFailGettingApnsToken) {
      _currentAttemptsToGetApnsToken++;
      return null;
    }
    return 'apns_token';
  }

  @override
  Future<String?> getToken({String? vapidKey}) async {
    if (_currentAttemptsToGetToken < _attemptsToFailGettingToken) {
      _currentAttemptsToGetToken++;
      throw Exception('Failed to get token');
    }
    return _tokenToReturn;
  }

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    return _initialMessageToReturn;
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    _foregroundPresentationAlertRequested = alert;
    _foregroundPresentationBadgeRequested = badge;
    _foregroundPresentationSoundRequested = sound;
  }

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
  }) async {
    _permissionsRequested = true;

    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.authorized,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.enabled,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.enabled,
      criticalAlert: AppleNotificationSetting.enabled,
      sound: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.enabled,
    );
  }

  @override
  Stream<RemoteMessage> get onMessage => const Stream<RemoteMessage>.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      const Stream<RemoteMessage>.empty();

  @override
  void setBackgroundHandler(BackgroundMessageHandler handler) {
    backgroundMessageHandler = handler;
  }

  Future<void> emitRefreshTokens(List<String> list) async {
    await Future.wait(
      list.map((token) async => _deviceTokenRefreshController.add(token)),
    );
  }
}
