import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart' as sqlite_open;

import 'infrastructure/configuration/environment.dart';
import 'infrastructure/firebase_messaging/firebase_options.dart';
import 'infrastructure/firebase_messaging/firebase_push_notification_messaging.dart';
import 'infrastructure/loggers/app_logger/app_logger.dart';
import 'infrastructure/loggers/error_logger/error_logger.dart';
import 'infrastructure/loggers/riverpod_provider_logger/provider_debug_logger.dart';
import 'infrastructure/plugins/camera_attachments_plugin/camera_attachments_plugin.dart';
import 'infrastructure/plugins/device_region_plugin/device_region_plugin.dart';
import 'infrastructure/plugins/gallery_attachments_plugin/gallery_attachments_plugin.dart';
import 'infrastructure/plugins/r_card_attachments_plugin/r_card_attachments_plugin.dart';
import 'infrastructure/plugins/vrc_attachments_plugin/vrc_attachments_plugin.dart';
import 'infrastructure/providers/available_attachment_plugins_provider.dart';
import 'infrastructure/providers/cache_manager_provider.dart';
import 'infrastructure/providers/channel_repository_provider.dart';
import 'infrastructure/providers/chat_repository_provider.dart';
import 'infrastructure/providers/connection_offer_repository_provider.dart';
import 'infrastructure/providers/contacts_repository_provider.dart';
import 'infrastructure/providers/group_repository_provider.dart';
import 'infrastructure/providers/identities_repository_provider.dart';
import 'infrastructure/providers/liveness_credentials_repository_provider.dart';
import 'infrastructure/providers/mediators_repository_provider.dart';
import 'infrastructure/providers/push_notification_messaging_provider.dart';
import 'infrastructure/providers/r_cards_repository_provider.dart';
import 'infrastructure/providers/shared_preferences_provider.dart';
import 'infrastructure/repositories/contacts_repository/contacts_repository_drift/contacts_repository_drift.dart';
import 'infrastructure/repositories/identities_repository/identities_repository_drift/identities_repository_drift.dart';
import 'infrastructure/repositories/liveness_credentials_repository/liveness_credentials_repository_secure_storage.dart';
import 'infrastructure/repositories/mediators_repository/mediators_repository_drift/mediators_repository_drift.dart';
import 'presentation/app/app.dart';

bool _isSqliteConfigured = false;

Future<void> _configureSqlite() async {
  if (_isSqliteConfigured) {
    return;
  }

  sqlite_open.open.overrideFor(
    sqlite_open.OperatingSystem.android,
    openCipherOnAndroid,
  );
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
  _isSqliteConfigured = true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureSqlite();
  await DeviceRegionPlugin.initialize();
  final dir = await getApplicationDocumentsDirectory();
  AppLogger.initialize(
    File('${dir.path}/app_debug.log'),
    maxLogMemoryEntries: Environment.instance.maxLogMemoryEntries,
  );
  ErrorLoggingHandler.instance.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final sharedPreferences = await SharedPreferences.getInstance();

  final logger = AppLogger.instance;
  const logKey = 'Main';

  logger.info(
    'MeetingPlaceCoreSDK logger configured to use debug collector',
    name: logKey,
  );

  logger.info('Application starting up', name: logKey);
  logger.info(
    'Flutter version: ${FlutterVersion.version ?? 'unknown'}',
    name: logKey,
  );
  logger.info('Build mode: ${kDebugMode ? 'debug' : 'release'}', name: logKey);

  logger.info('Launching Flutter app with ProviderScope', name: logKey);
  runApp(
    ProviderScope(
      overrides: [
        availableAttachmentPluginsProvider.overrideWith(
          (ref) => [
            CameraAttachmentsPlugin(
              cacheManager: ref.read(cacheManagerProvider),
            ),
            GalleryAttachmentsPlugin(
              cacheManager: ref.read(cacheManagerProvider),
            ),
            RCardAttachmentsPlugin(
              cacheManager: ref.read(cacheManagerProvider),
            ),
            VrcAttachmentsPlugin(),
          ],
        ),
        channelRepositoryProvider.overrideWith(channelRepositoryDrift),
        chatRepositoryProvider.overrideWith(chatRepositoryDrift),
        connectionOfferRepositoryProvider.overrideWith(
          connectionOfferRepositoryDrift,
        ),
        contactsRepositoryProvider.overrideWith(contactsRepositoryDrift),
        groupsRepositoryProvider.overrideWith(groupsRepositoryDrift),
        identitiesRepositoryProvider.overrideWith(identitiesRepositoryDrift),
        livenessCredentialsRepositoryProvider.overrideWith(
          livenessCredentialsRepositorySecureStorage,
        ),
        mediatorsRepositoryProvider.overrideWith(mediatorsRepositoryDrift),
        rCardsRepositoryProvider.overrideWith(rCardsRepositoryDrift),
        pushNotificationMessagingProvider.overrideWith(
          (ref) =>
              FirebasePushNotificationMessaging(FirebaseMessaging.instance)
                ..setBackgroundHandler(firebaseMessagingBackgroundHandler),
        ),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      observers: [ProviderDebugLogger()],
      child: const App(),
    ),
  );

  logger.info('Application launch completed', name: logKey);
}
