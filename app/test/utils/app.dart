import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/mediator/mediator.dart';
import 'package:mpx_flutter_reference_app/infrastructure/biometrics/local_auth_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/app_info.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/firebase_messaging/push_notification_messaging.dart';
import 'package:mpx_flutter_reference_app/infrastructure/media/image_picker/image_picker_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_info_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/applications_documents_directory_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/connectivity_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';
import 'package:mpx_flutter_reference_app/mpx_flutter_reference_app.dart';
import 'package:mpx_flutter_reference_app/presentation/app/app.dart';

import '../fakes/fake_app_badge_service.dart';
import '../fakes/fake_cache_manager.dart';
import '../fakes/fake_camera_service.dart';
import '../fakes/fake_channels.dart';
import '../fakes/fake_chat_repository.dart';
import '../fakes/fake_connectivity.dart';
import '../fakes/fake_contacts_service.dart';
import '../fakes/fake_environment.dart';
import '../fakes/fake_local_authentication.dart';
import '../fakes/fake_meeting_place_sdk.dart';
import '../fakes/fake_push_notification_messaging.dart';
import '../fakes/fake_secure_storage.dart';

/// Callback type for wrapping the real Chat SDK.
typedef ChatSDKWrapper = MeetingPlaceChatSDK Function(
    MeetingPlaceChatSDK realSdk);

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
  MeetingPlaceChatSDK? meetingPlaceChatSDK,
  ChatSDKWrapper? chatSdkWrapper,
  ImagePicker? imagePicker,
  FakeCameraService? cameraService,
  required List<Identity> identities,
  required List<Mediator> mediators,
  List<Contact> contacts = const [],
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
      availableAttachmentPluginsProvider.overrideWith((ref) => [
            CameraAttachmentsPlugin(
              cacheManager: ref.read(cacheManagerProvider),
            ),
            GalleryAttachmentsPlugin(
              cacheManager: ref.read(cacheManagerProvider),
            ),
          ]),
      localAuthProvider.overrideWith(
          (ref) => FakeLocalAuthentication(isAuthenticated: isAuthenticated)),
      cacheManagerProvider.overrideWith((ref) => FakeCacheManager()),
      chatRepositoryProvider.overrideWith((ref) async => FakeChatRepository()),
      environmentProvider.overrideWithValue(FakeEnvironment()),
      channelRepositoryProvider.overrideWith(channelRepositoryInMemoryDrift),
      connectionOfferRepositoryProvider
          .overrideWith(connectionOfferRepositoryInMemoryDrift),
      connectivityProvider
          .overrideWith((ref) => connectivity ?? FakeConnectivity()),
      contactsRepositoryProvider.overrideWith((ref) async {
        final repo = await contactsRepositoryInMemoryDrift(ref);
        // Add all contacts and wait for them to be persisted
        for (final contact in contacts) {
          await repo.addContact(contact);
        }
        // Give a small delay to ensure all database operations complete
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return repo;
      }),
      if (contacts.isNotEmpty)
        contactsServiceProvider
            .overrideWith(() => FakeContactsService(contacts)),
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
      meetingPlaceSdkProvider.overrideWith((ref) =>
          meetingPlaceCoreSDK ??
          FakeMeetingPlaceSDK(
            channels: contacts.isNotEmpty ? FakeChannels.allChannels : null,
          )),
      if (meetingPlaceChatSDK != null)
        chatSdkProvider
            .overrideWith((ref, channel) async => meetingPlaceChatSDK),
      // If a wrapper is provided, wrap the real SDK after it's created
      if (chatSdkWrapper != null && meetingPlaceChatSDK == null)
        chatSdkProvider.overrideWith((ref, channel) async {
          final coreSDK = await ref.read(meetingPlaceSdkProvider.future);
          final realSdk = await MeetingPlaceChatSDK.initialiseFromChannel(
            channel,
            coreSDK: coreSDK,
            chatRepository: await ref.read(chatRepositoryProvider.future),
            options: ChatSDKOptions(
              chatActivityExpiry: const Duration(seconds: 60),
              chatPresenceSendInterval: const Duration(seconds: 30),
            ),
            logger: ref.read(appLoggerProvider),
          );
          return chatSdkWrapper(realSdk);
        }),
      if (imagePicker != null)
        imagePickerProvider.overrideWith((ref) => imagePicker),
      if (cameraService != null)
        cameraServiceProvider
            .overrideWith(() => FakeCameraServiceNotifier(cameraService)),
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
  List<Contact> contacts = const [],
  PushNotificationMessaging? pushNotificationMessaging,
  Connectivity? connectivity,
  MeetingPlaceCoreSDK? meetingPlaceCoreSDK,
  MeetingPlaceChatSDK? meetingPlaceChatSDK,
  ChatSDKWrapper? chatSdkWrapper,
  ImagePicker? imagePicker,
  FakeCameraService? cameraService,
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
    meetingPlaceChatSDK: meetingPlaceChatSDK,
    chatSdkWrapper: chatSdkWrapper,
    imagePicker: imagePicker,
    cameraService: cameraService,
    secureStorage: secureStorage,
    mediators: mediators,
    contacts: contacts,
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
