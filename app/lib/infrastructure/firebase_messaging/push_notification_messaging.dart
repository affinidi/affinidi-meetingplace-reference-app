import 'package:firebase_messaging/firebase_messaging.dart';

abstract class PushNotificationMessaging {
  Stream<RemoteMessage> get onMessage;
  Stream<String> get onTokenRefresh;
  Future<String?> getAPNSToken();
  Future<String?> getToken({String? vapidKey});
  Future<RemoteMessage?> getInitialMessage();
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  });
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  });
  void setBackgroundHandler(BackgroundMessageHandler handler);
  Stream<RemoteMessage> get onMessageOpenedApp;
}
