import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
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
import 'package:mpx_flutter_reference_app/infrastructure/providers/applications_documents_directory_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/connectivity_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/qr_code_view_factory_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/share_service_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/r_card_repository/r_card_repository_drift/r_cards_repository_drift.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/share_plus_service/share_plus_service.dart';
import 'package:mpx_flutter_reference_app/mpx_flutter_reference_app.dart';
import 'package:mpx_flutter_reference_app/presentation/app/app.dart';
import 'package:permission_handler/permission_handler.dart';

import '../fakes/fake_app_badge_service.dart';
import '../fakes/fake_cache_manager.dart';
import '../fakes/fake_camera_controller.dart';
import '../fakes/fake_channels.dart';
import '../fakes/fake_connectivity.dart';
import '../fakes/fake_environment.dart';
import '../fakes/fake_local_authentication.dart';
import '../fakes/fake_meeting_place_sdk.dart';
import '../fakes/fake_permission_service.dart';
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
  MeetingPlaceChatSDK? meetingPlaceChatSDK,
  ImagePicker? imagePicker,
  List<CameraDescription>? mockCameras,
  PermissionStatus? cameraPermissionStatus,
  required List<Identity> identities,
  required List<Mediator> mediators,
  List<Contact> contacts = const [],
  SecureStorage? secureStorage,
  ShareService? shareService,
  QrCodeViewFactory? qrCodeViewFactory,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));
  SharedPreferences.setMockInitialValues({
    'alreadyOnboarded': alreadyOnboarded,
  });
  final sharedPreferences = await SharedPreferences.getInstance();
  final cacheManager = FakeCacheManager();

  final app = ProviderScope(
    overrides: [
      cacheManagerProvider.overrideWith((ref) => cacheManager),
      appBadgeServiceProvider.overrideWithValue(FakeAppBadgeService()),
      appInfoProvider.overrideWith(
        (ref) =>
            AppInfo(versionName: 'Test', buildNumber: '1', version: '0.0.0'),
      ),
      applicationDocumentsDirectoryProvider.overrideWith(
        (ref) async => Directory('/tmp'),
      ),
      availableAttachmentPluginsProvider.overrideWith(
        (ref) => [
          CameraAttachmentsPlugin(cacheManager: ref.read(cacheManagerProvider)),
          GalleryAttachmentsPlugin(
            cacheManager: ref.read(cacheManagerProvider),
          ),
        ],
      ),
      localAuthProvider.overrideWith(
        (ref) => FakeLocalAuthentication(isAuthenticated: isAuthenticated),
      ),
      chatRepositoryProvider.overrideWith(chatRepositoryInMemoryDrift),
      environmentProvider.overrideWithValue(FakeEnvironment()),
      channelRepositoryProvider.overrideWith(channelRepositoryInMemoryDrift),
      connectionOfferRepositoryProvider.overrideWith(
        connectionOfferRepositoryInMemoryDrift,
      ),
      connectivityProvider.overrideWith(
        (ref) => connectivity ?? FakeConnectivity(),
      ),
      contactsRepositoryProvider.overrideWith((ref) async {
        final repo = await contactsRepositoryInMemoryDrift(ref);
        for (final contact in contacts) {
          await repo.addContact(contact);
        }
        return repo;
      }),
      environmentProvider.overrideWith((ref) => FakeEnvironment()),
      pushNotificationMessagingProvider.overrideWith(
        (ref) => pushNotificationMessaging ?? FakePushNotificationMessaging(),
      ),
      groupsRepositoryProvider.overrideWith(groupsRepositoryInMemoryDrift),
      rCardsRepositoryProvider.overrideWith(rCardsRepositoryInMemoryDrift),
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
      meetingPlaceSdkProvider.overrideWith(
        (ref) =>
            meetingPlaceCoreSDK ??
            FakeMeetingPlaceSDK(
              channels: contacts.isNotEmpty ? FakeChannels.allChannels : null,
            ),
      ),
      if (meetingPlaceChatSDK != null)
        chatSdkProvider.overrideWith(
          (ref, channel) async => meetingPlaceChatSDK,
        ),
      if (imagePicker != null)
        imagePickerProvider.overrideWith((ref) => imagePicker),
      if (mockCameras != null) ...[
        availableCamerasProvider.overrideWith(
          (ref) =>
              () async => mockCameras,
        ),
        cameraControllerFactoryProvider.overrideWith(
          (ref) =>
              (
                description,
                resolutionPreset, {
                enableAudio = true,
                imageFormatGroup,
              }) => FakeCameraController(
                description,
                resolutionPreset,
                enableAudio: enableAudio,
                imageFormatGroup: imageFormatGroup,
              ),
        ),
      ],
      if (cameraPermissionStatus != null)
        permissionServiceProvider.overrideWith(
          (ref) => FakePermissionService(
            cameraPermissionStatus: cameraPermissionStatus,
          ),
        ),
      secureStorageProvider.overrideWith(
        (ref) async => secureStorage ?? FakeSecureStorage(),
      ),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      if (shareService != null)
        shareServiceProvider.overrideWith((ref) => shareService),
      if (qrCodeViewFactory != null)
        qrCodeViewFactoryProvider.overrideWith((ref) => qrCodeViewFactory),
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
  ImagePicker? imagePicker,
  List<CameraDescription>? mockCameras,
  PermissionStatus? cameraPermissionStatus = PermissionStatus.granted,
  SecureStorage? secureStorage,
  ShareService? shareService,
  QrCodeViewFactory? qrCodeViewFactory,
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
    imagePicker: imagePicker,
    mockCameras: mockCameras,
    cameraPermissionStatus: cameraPermissionStatus,
    secureStorage: secureStorage,
    mediators: mediators,
    contacts: contacts,
    shareService: shareService,
    qrCodeViewFactory: qrCodeViewFactory,
  );

  await tester.pumpAndSettle();

  final testRouteInformation = <String, dynamic>{'location': location};
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
