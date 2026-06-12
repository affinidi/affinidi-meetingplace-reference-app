import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_messaging/push_notification_messaging.dart';

/// Provides a [FutureProvider] for initializing and accessing
///  [PushNotificationMessaging].
///
/// Sets up background message handling and ensures Firebase is initialized
/// with the correct platform options.
FutureProvider<PushNotificationMessaging> pushNotificationMessagingProvider =
    FutureProvider<PushNotificationMessaging>((ref) async {
      throw UnimplementedError(
        'Make sure to override pushNotificationMessagingProvider',
      );
    });
