import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/mediator/mediator.dart';
import 'package:mpx_flutter_reference_app/infrastructure/biometrics/local_auth_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/app_info.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/firebase_messaging/push_notification_messaging.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_info_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/applications_documents_directory_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/connectivity_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';
import 'package:mpx_flutter_reference_app/mpx_flutter_reference_app.dart';
import 'package:mpx_flutter_reference_app/presentation/app/app.dart';

import '../fakes/fake_app_badge_service.dart';
import '../fakes/fake_cache_manager.dart';
import '../fakes/fake_connections_service.dart';
import '../fakes/fake_connectivity.dart';
import '../fakes/fake_environment.dart';
import '../fakes/fake_local_authentication.dart';
import '../fakes/fake_meeting_place_sdk.dart';
import '../fakes/fake_push_notification_messaging.dart';
import '../fakes/fake_secure_storage.dart';

Future<void> startApp(
  WidgetTester tester, {
  MediaQueryData data = const MediaQueryData(),
  Locale locale = const Locale('en', 'US'),
  bool isAuthenticated = true,
  bool hasNetworkConnection = true,
  bool alreadyOnboarded = true,
  PushNotificationMessaging? pushNotificationMessaging,
  Connectivity? connectivity,
  MeetingPlaceCoreSDK? meetingPlaceCoreSDK,
  required List<Identity> identities,
  required List<Mediator> mediators,
  SecureStorage? secureStorage,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({
    'alreadyOnboarded': alreadyOnboarded,
  });
  final sharedPreferences = await SharedPreferences.getInstance();

  final app = ProviderScope(
    overrides: [
      appBadgeServiceProvider.overrideWithValue(FakeAppBadgeService()),
      appInfoProvider.overrideWith((ref) =>
          AppInfo(versionName: 'Test', buildNumber: '1', version: '0.0.0')),
      applicationDocumentsDirectoryProvider
          .overrideWith((ref) async => Directory('/tmp')),
      localAuthProvider.overrideWith(
          (ref) => FakeLocalAuthentication(isAuthenticated: isAuthenticated)),
      cacheManagerProvider.overrideWith((ref) => FakeCacheManager()),
      environmentProvider.overrideWithValue(FakeEnvironment()),
      channelRepositoryProvider.overrideWith(channelRepositoryInMemoryDrift),
      connectionOfferRepositoryProvider
          .overrideWith(connectionOfferRepositoryInMemoryDrift),
      connectivityProvider
          .overrideWith((ref) => connectivity ?? FakeConnectivity()),
      contactsRepositoryProvider.overrideWith(contactsRepositoryInMemoryDrift),
      environmentProvider.overrideWith((ref) => FakeEnvironment()),
      pushNotificationMessagingProvider.overrideWith((ref) =>
          pushNotificationMessaging ?? FakePushNotificationMessaging()),
      groupsRepositoryProvider.overrideWith(groupsRepositoryInMemoryDrift),
      identitiesRepositoryProvider.overrideWith((ref) async {
        final repo = await identitiesRepositoryInMemoryDrift(ref);
        for (final identity in identities) {
          await repo.addIdentity(identity);
        }
        return repo;
      }),
      mediatorsRepositoryProvider.overrideWith((ref) async {
        final repo = await mediatorsRepositoryInMemoryDrift(ref);
        for (final mediator in mediators) {
          await repo.addCustomMediator(
            name: mediator.mediatorName,
            did: mediator.mediatorDid,
          );
        }
        return repo;
      }),
      meetingPlaceSdkProvider
          .overrideWith((ref) => meetingPlaceCoreSDK ?? FakeMeetingPlaceSDK()),
      secureStorageProvider
          .overrideWith((ref) async => secureStorage ?? FakeSecureStorage()),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: MediaQuery(
      data: data,
      child: App(locale: locale),
    ),
  );

  await tester.pumpWidget(app);
}

Future<void> navigateToLocation(
  WidgetTester tester,
  String location, {
  bool isAuthenticated = true,
  bool alreadyOnboarded = true,
  List<Identity> identities = const [],
  List<Mediator> mediators = const [],
  PushNotificationMessaging? pushNotificationMessaging,
  Connectivity? connectivity,
  MeetingPlaceCoreSDK? meetingPlaceCoreSDK,
  SecureStorage? secureStorage,
}) async {
  await startApp(
    tester,
    isAuthenticated: isAuthenticated,
    alreadyOnboarded: alreadyOnboarded,
    identities: identities,
    pushNotificationMessaging: pushNotificationMessaging,
    connectivity: connectivity,
    meetingPlaceCoreSDK: meetingPlaceCoreSDK,
    secureStorage: secureStorage,
    mediators: mediators,
  );

  await tester.pumpAndSettle();

  final testRouteInformation = <String, dynamic>{
    'location': location,
  };
  final message = const JSONMethodCodec().encodeMethodCall(
    MethodCall('pushRouteInformation', testRouteInformation),
  );
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage('flutter/navigation', message, (_) {});
}

Future<AppLocalizations> getL10n({
  Locale locale = const Locale('en', 'US'),
}) async {
  return await AppLocalizations.delegate.load(locale);
}
