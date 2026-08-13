import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:mpx_flutter_reference_app/application/services/context_routing_service/context_routing_service.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/r_cards_service/r_cards_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/mediator/mediator.dart';
import 'package:mpx_flutter_reference_app/infrastructure/biometrics/local_auth_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/app_info.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/firebase_messaging/push_notification_messaging.dart';
import 'package:mpx_flutter_reference_app/infrastructure/media/file_picker/file_picker_platform_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/media/image_picker/image_picker_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/audio_attachments_plugin/audio_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/audio_attachments_plugin/local_voice_attachment_store.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/document_attachments_plugin/document_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/r_card_attachments_plugin/r_card_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_info_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/applications_documents_directory_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/connectivity_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/liveness_credentials_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/qr_code_view_factory_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/share_service_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/vrc_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/liveness_credentials_repository/liveness_credentials_repository_secure_storage.dart';
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
import '../fakes/fake_chat_sdk.dart';
import '../fakes/fake_connectivity.dart';
import '../fakes/fake_contacts.dart';
import '../fakes/fake_context_routing_store.dart';
import '../fakes/fake_environment.dart';
import '../fakes/fake_identities.dart';
import '../fakes/fake_local_authentication.dart';
import '../fakes/fake_meeting_place_sdk.dart';
import '../fakes/fake_permission_service.dart';
import '../fakes/fake_push_notification_messaging.dart';
import '../fakes/fake_secure_storage.dart';

Future<void> startApp(
  WidgetTester tester, {
  MediaQueryData? data,
  Locale locale = const Locale('en', 'US'),
  bool isAuthenticated = true,
  bool hasMnemonicConfigured = true,
  bool hasNetworkConnection = true,
  bool alreadyOnboarded = true,
  PushNotificationMessaging? pushNotificationMessaging,
  Connectivity? connectivity,
  MeetingPlaceMatrixSDK? meetingPlaceCoreSDK,
  MeetingPlaceMatrixChatSDK? meetingPlaceChatSDK,
  ImagePicker? imagePicker,
  FilePickerPlatform? filePickerPlatform,
  List<CameraDescription>? mockCameras,
  PermissionStatus? cameraPermissionStatus,
  required List<Identity> identities,
  required List<Mediator> mediators,
  List<Contact> contacts = const [],
  List<RCard> rCards = const [],
  List<Vrc> vrcs = const [],
  SecureStorage? secureStorage,
  ShareService? shareService,
  QrCodeViewFactory? qrCodeViewFactory,
  List<AttachmentPlugin>? attachmentPlugins,
  RCardsService Function()? rCardsServiceFactory,
  Environment? environment,
  PersonalAiServiceState? personalAiState,
  ContextRoutingStore? contextRoutingStore,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  addTearDown(() async {
    await _closeChat(tester);
  });
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));
  SharedPreferences.setMockInitialValues({
    'alreadyOnboarded': alreadyOnboarded,
    SharedPreferencesKeys.hasMnemonic.name: hasMnemonicConfigured,
  });
  final sharedPreferences = await SharedPreferences.getInstance();
  final cacheManager = FakeCacheManager();
  final effectiveEnvironment = environment ?? FakeEnvironment();
  final effectiveSecureStorage = secureStorage ?? FakeSecureStorage();
  final documentsDirectory = Directory('/tmp');
  final databasePassphrase = await effectiveSecureStorage
      .provideDatabasePassphrase();
  final rCardDatabase = RCardDatabase(
    databaseName: 'mpx_received_rcards_db',
    passphrase: databasePassphrase,
    directory: documentsDirectory,
    logStatements: effectiveEnvironment.isDatabaseLoggingEnabled,
    inMemory: true,
  );
  final vrcDatabase = VrcDatabase(
    databaseName: 'mpx_vrc_db',
    passphrase: databasePassphrase,
    directory: documentsDirectory,
    logStatements: effectiveEnvironment.isDatabaseLoggingEnabled,
    inMemory: true,
  );
  final rCardRepository = RCardRepositoryDrift(database: rCardDatabase);
  final vrcRepository = VrcRepositoryDrift(database: vrcDatabase);
  for (final vrc in vrcs) {
    await vrcRepository.upsert(vrc);
  }

  addTearDown(() async {
    await vrcDatabase.close();
    await rCardDatabase.close();
  });

  final app = ProviderScope(
    overrides: [
      cacheManagerProvider.overrideWith((ref) => cacheManager),
      appBadgeServiceProvider.overrideWithValue(FakeAppBadgeService()),
      appInfoProvider.overrideWith(
        (ref) =>
            AppInfo(versionName: 'Test', buildNumber: '1', version: '0.0.0'),
      ),
      applicationDocumentsDirectoryProvider.overrideWith(
        (ref) async => documentsDirectory,
      ),
      availableAttachmentPluginsProvider.overrideWith(
        (ref) =>
            attachmentPlugins ??
            [
              CameraAttachmentsPlugin(
                cacheManager: ref.read(cacheManagerProvider),
              ),
              GalleryAttachmentsPlugin(
                cacheManager: ref.read(cacheManagerProvider),
              ),
              RCardAttachmentsPlugin(
                cacheManager: ref.read(cacheManagerProvider),
              ),
              DocumentAttachmentsPlugin(
                cacheManager: ref.read(cacheManagerProvider),
                filePickerPlatform: ref.read(filePickerPlatformProvider),
              ),
              VrcAttachmentsPlugin(),
              AudioAttachmentsPlugin(
                cacheManager: ref.read(cacheManagerProvider),
                localVoiceStore: ref.read(localVoiceAttachmentStoreProvider),
              ),
            ],
      ),
      localAuthProvider.overrideWith(
        (ref) => FakeLocalAuthentication(isAuthenticated: isAuthenticated),
      ),
      chatRepositoryProvider.overrideWith(chatRepositoryInMemoryDrift),
      environmentProvider.overrideWithValue(effectiveEnvironment),
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
      pushNotificationMessagingProvider.overrideWith(
        (ref) => pushNotificationMessaging ?? FakePushNotificationMessaging(),
      ),
      contextRoutingStoreProvider.overrideWith(
        (ref) => contextRoutingStore ?? FakeContextRoutingStore(),
      ),
      groupsRepositoryProvider.overrideWith(groupsRepositoryInMemoryDrift),
      rCardsRepositoryProvider.overrideWith((ref) async {
        for (final card in rCards) {
          await rCardRepository.upsert(card);
        }
        return rCardRepository;
      }),
      vrcRepositoryProvider.overrideWith((ref) async => vrcRepository),
      identitiesRepositoryProvider.overrideWith((ref) async {
        final repo = await identitiesRepositoryInMemoryDrift(ref);
        for (final identity in identities) {
          await repo.addIdentity(identity);
        }
        return repo;
      }),
      livenessCredentialsRepositoryProvider.overrideWith(
        livenessCredentialsRepositorySecureStorage,
      ),
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
      if (filePickerPlatform != null)
        filePickerPlatformProvider.overrideWith((ref) => filePickerPlatform),
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
      secureStorageProvider.overrideWith((ref) async => effectiveSecureStorage),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      if (rCardsServiceFactory != null)
        rCardsServiceProvider.overrideWith(rCardsServiceFactory),
      if (shareService != null)
        shareServiceProvider.overrideWith((ref) => shareService),
      if (qrCodeViewFactory != null)
        qrCodeViewFactoryProvider.overrideWith((ref) => qrCodeViewFactory),
      if (personalAiState != null)
        personalAiServiceProvider.overrideWith(
          (ref) => _TestPersonalAiNotifier(personalAiState),
        ),
    ],
    child: data == null
        ? App(locale: locale)
        : MediaQuery(
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
  bool hasMnemonicConfigured = true,
  bool alreadyOnboarded = true,
  List<Identity> identities = const [],
  List<Mediator> mediators = const [],
  List<Contact> contacts = const [],
  List<RCard> rCards = const [],
  List<Vrc> vrcs = const [],
  PushNotificationMessaging? pushNotificationMessaging,
  Connectivity? connectivity,
  MeetingPlaceMatrixSDK? meetingPlaceCoreSDK,
  MeetingPlaceMatrixChatSDK? meetingPlaceChatSDK,
  ImagePicker? imagePicker,
  List<CameraDescription>? cameras,
  PermissionStatus? cameraPermissionStatus = PermissionStatus.granted,
  SecureStorage? secureStorage,
  ShareService? shareService,
  QrCodeViewFactory? qrCodeViewFactory,
  List<AttachmentPlugin>? attachmentPlugins,
  RCardsService Function()? rCardsServiceFactory,
  Environment? environment,
  PersonalAiServiceState? personalAiState,
  ContextRoutingStore? contextRoutingStore,
}) async {
  await startApp(
    tester,
    isAuthenticated: isAuthenticated,
    hasMnemonicConfigured: hasMnemonicConfigured,
    alreadyOnboarded: alreadyOnboarded,
    identities: identities,
    pushNotificationMessaging: pushNotificationMessaging,
    connectivity: connectivity,
    meetingPlaceCoreSDK: meetingPlaceCoreSDK,
    meetingPlaceChatSDK: meetingPlaceChatSDK,
    imagePicker: imagePicker,
    mockCameras: cameras,
    cameraPermissionStatus: cameraPermissionStatus,
    secureStorage: secureStorage,
    mediators: mediators,
    contacts: contacts,
    rCards: rCards,
    vrcs: vrcs,
    shareService: shareService,
    qrCodeViewFactory: qrCodeViewFactory,
    attachmentPlugins: attachmentPlugins,
    rCardsServiceFactory: rCardsServiceFactory,
    environment: environment,
    personalAiState: personalAiState,
    contextRoutingStore: contextRoutingStore,
  );

  await tester.pumpAndSettle();

  await pushRoute(tester, location);
}

Future<void> pushRoute(WidgetTester tester, String location) async {
  final testRouteInformation = <String, dynamic>{'location': location};
  final message = const JSONMethodCodec().encodeMethodCall(
    MethodCall('pushRouteInformation', testRouteInformation),
  );
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage('flutter/navigation', message, (_) {});
  await tester.pumpAndSettle();
}

Future<void> navigateToChat(
  WidgetTester tester, {
  String contactId = 'individual-contact-id',
  FakeChatSdk? chatSdk,
  List<Identity>? identities,
  List<Contact>? contacts,
  Connectivity? connectivity,
  FakeSecureStorage? secureStorage,
  ImagePicker? imagePicker,
  List<CameraDescription>? cameras,
  PermissionStatus? cameraPermissionStatus,
  bool isAuthenticated = true,
  bool alreadyOnboarded = true,
  List<AttachmentPlugin>? attachmentPlugins,
  RCardsService Function()? rCardsServiceFactory,
  List<RCard> rCards = const [],
  MeetingPlaceMatrixSDK? meetingPlaceCoreSDK,
  FakeEnvironment? environment,
  PersonalAiServiceState? personalAiState,
  ContextRoutingStore? contextRoutingStore,
}) async {
  await navigateToLocation(
    tester,
    '/contacts/$contactId/chat',
    hasMnemonicConfigured: true,
    identities: identities ?? [FakeIdentities.primaryIdentity],
    contacts: contacts ?? [FakeContacts.individualContact],
    meetingPlaceChatSDK: chatSdk ?? FakeChatSdk(),
    meetingPlaceCoreSDK: meetingPlaceCoreSDK,
    secureStorage: secureStorage,
    connectivity:
        connectivity ??
        FakeConnectivity(
          initialConnectivityToReturn: [ConnectivityResult.wifi],
        ),
    imagePicker: imagePicker,
    cameras: cameras,
    cameraPermissionStatus: cameraPermissionStatus,
    isAuthenticated: isAuthenticated,
    alreadyOnboarded: alreadyOnboarded,
    attachmentPlugins: attachmentPlugins,
    rCardsServiceFactory: rCardsServiceFactory,
    rCards: rCards,
    environment: environment,
    personalAiState: personalAiState,
    contextRoutingStore: contextRoutingStore,
  );
  await tester.pumpAndSettle();
}

class _TestPersonalAiNotifier extends StateNotifier<PersonalAiServiceState>
    implements PersonalAiService {
  _TestPersonalAiNotifier(super.state);

  @override
  Future<void> refreshAuthorizationSnapshotForChannel(
    String channelDid, {
    bool suppressErrors = true,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> _closeChat(WidgetTester tester) async {
  final binding = tester.binding;

  try {
    for (final state in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      binding.handleAppLifecycleStateChanged(state);
      await tester.pump();
    }
    await tester.pumpAndSettle();
  } catch (_) {
    // Ignore teardown-time settle failures when the tree is already gone.
  }

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

Future<AppLocalizations> getL10n({
  Locale locale = const Locale('en', 'US'),
}) async {
  return await AppLocalizations.delegate.load(locale);
}
