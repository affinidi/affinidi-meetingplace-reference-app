import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
import 'package:matrix/matrix.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:ssi/ssi.dart';

import '../../application/services/settings_service/settings_service.dart';
import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import '../services/matrix/flutter_matrix_rtc_delegate.dart';
import 'app_logger_provider.dart';
import 'channel_repository_provider.dart';
import 'connection_offer_repository_provider.dart';
import 'group_repository_provider.dart';

/// A provider that initializes and supplies the [MeetingPlaceCoreSDK]
/// instance.
///
/// This provider:
/// - Creates a [PersistentWallet] using [SecureStorage]
/// - Configures repositories ([ConnectionOfferRepository],
///   [ChannelRepository], [GroupRepository]) and key repository
/// - Uses mediator DID from settings and control plane DID from environment
/// - Provides comprehensive logging throughout the initialization process
/// - Handles initialization errors gracefully with proper error logging
final meetingPlaceSdkProvider = FutureProvider<MeetingPlaceCoreSDK>((
  ref,
) async {
  const logKey = 'meetingPlaceSdkProvider';
  final logger = ref.read(appLoggerProvider);
  final secureStorage = await ref.read(secureStorageProvider.future);

  try {
    final wallet = PersistentWallet(secureStorage);
    final settingsState = ref.read(settingsServiceProvider);
    final initialMediatorDid = settingsState.selectedMediatorDid;
    logger.info('Starting MeetingPlace SDK initialization', name: logKey);
    logger.info('Selected mediator: $initialMediatorDid', name: logKey);
    logger.info(
      'Service DID: ${ref.read(environmentProvider).controlPlaneDid}',
      name: logKey,
    );
    logger.info('Debug mode: ${settingsState.isDebugMode}', name: logKey);

    await vod.init();

    final sdk = await MeetingPlaceCoreSDK.create(
      wallet: wallet,
      repositoryConfig: RepositoryConfig(
        connectionOfferRepository: await ref.read(
          connectionOfferRepositoryProvider.future,
        ),
        channelRepository: await ref.read(channelRepositoryProvider.future),
        groupRepository: await ref.read(groupsRepositoryProvider.future),
        keyRepository: secureStorage,
      ),
      mediatorDid: initialMediatorDid,
      controlPlaneDid: ref.read(environmentProvider).controlPlaneDid,
      matrixClientFactory: (did) async {
        // Each DID gets its own SQLite file so Olm identity keys are never
        // shared or overwritten between users on the same device.
        final key = md5.convert(utf8.encode(did)).toString();
        final database = await MatrixSdkDatabase.init(
          'matrix_$key',
          database: await sqlite.openDatabase('./data/matrix_$key.sqlite'),
        );
        final client = Client('matrix_client_$key', database: database);
        client.homeserver = Uri.parse('http://localhost:9000');
        return client;
      },
      logger: logger,
    );

    // Initialize MatrixRTC VoIP layer with a Flutter WebRTC delegate.
    // Must happen after SDK creation and before any group call is started.
    sdk.initializeMatrixRTC(FlutterMatrixRTCDelegate());

    logger.info('Completed initializing MeetingPlace SDK', name: logKey);

    return sdk;
  } catch (error, stackTrace) {
    logger.error(
      'Error initializing MeetingPlace SDK',
      error: error,
      stackTrace: stackTrace,
      name: logKey,
    );
    rethrow;
  }
}, name: 'meetingPlaceSdkProvider');
