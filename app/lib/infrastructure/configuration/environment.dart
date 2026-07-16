import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'firebase_environment.dart';
import 'image_config.dart';

/// Centralized runtime configuration sourced from compile-time environment
/// variables and sensible defaults used across the app.
///
/// Factory parameters:
/// - [controlPlaneDid] - CONTROL_PLANE_DID compile-time environment value.
/// - [defaultMediatorDid] - DEFAULT_MEDIATOR_DID compile-time environment
///  value.
/// - [matrixHomeserver] - MATRIX_HOMESERVER compile-time environment value.
/// - [firebase] - FirebaseEnvironment singleton providing firebase-related
///  config.
/// - [maxOfferUsages] - Maximum usages for offers.
/// - [isBiometricsEnabled] - Whether biometrics are enabled
///  (compile-time flag).
class Environment {
  Environment._();

  static final Environment _instance = Environment._();

  static final Environment instance = _instance;

  String get controlPlaneDid =>
      const String.fromEnvironment('CONTROL_PLANE_DID');

  String get defaultMediatorDid =>
      const String.fromEnvironment('DEFAULT_MEDIATOR_DID');

  String get matrixHomeserver =>
      const String.fromEnvironment('MATRIX_HOMESERVER');

  /// The Matrix server name derived from [matrixHomeserver]. Used for Matrix
  /// user ID derivation (`@hash:<serverName>`).
  String get matrixServerName {
    final uri = Uri.tryParse(matrixHomeserver);
    return uri?.host ?? matrixHomeserver;
  }

  String get livekitServiceUrl =>
      const String.fromEnvironment('LIVEKIT_SERVICE_URL');

  String get livekitSfuUrl => const String.fromEnvironment('LIVEKIT_SFU_URL');

  FirebaseEnvironment get firebase => FirebaseEnvironment.instance;

  int get maxOfferUsages => 100;

  int get maxLogMemoryEntries =>
      const int.fromEnvironment('MAX_LOG_MEMORY_ENTRIES', defaultValue: 1000);

  Duration get minimumExpiryOffset => const Duration(minutes: 5);
  Duration get defaultExpiryOffset => const Duration(days: 7);
  Duration get maximumExpiryOffset => const Duration(days: 365);
  Duration get inputDebounceDuration => const Duration(milliseconds: 800);
  Duration get initialTimeOffset => const Duration(minutes: 3);
  int get numberOfTapsToUnlockDebug =>
      const int.fromEnvironment('TAPS_TO_UNLOCK_DEBUG', defaultValue: 7);

  Duration get callRingTimeout => const Duration(
    seconds: int.fromEnvironment('CALL_RING_TIMEOUT_SECONDS', defaultValue: 60),
  );

  bool get isDatabaseLoggingEnabled =>
      const bool.fromEnvironment('DATABASE_LOGGING_ENABLED') && kDebugMode;
  bool get isForegroundNotificationsEnabled => const bool.fromEnvironment(
    'FOREGROUND_NOTIFICATIONS_ENABLED',
    defaultValue: false,
  );
  String get marketplaceQrPrefix =>
      const String.fromEnvironment('MARKETPLACE_QR_PREFIX');

  ImageConfig get chatImageConfig => ImageConfig(
    qualityPercentage: const int.fromEnvironment(
      'CHAT_IMAGE_QUALITY_PERCENT',
      defaultValue: 80,
    ),
    imageMaxSize: const int.fromEnvironment(
      'CHAT_IMAGE_MAX_SIZE',
      defaultValue: 800,
    ),
  );
  ImageConfig get profileImageConfig => ImageConfig(
    qualityPercentage: const int.fromEnvironment(
      'PROFILE_IMAGE_QUALITY_PERCENT',
      defaultValue: 80,
    ),
    imageMaxSize: const int.fromEnvironment(
      'PROFILE_IMAGE_MAX_SIZE',
      defaultValue: 100,
    ),
  );

  /// Event configuration keyed by sha256 hex of the wallet mnemonic.
  ///
  /// Each entry maps to a nested map of event options, e.g.:
  /// `{"<sha256>": {"ciergeConnectorDid": "did:key:..."}}`.
  /// Sourced from the `WALLET_CONFIG` compile-time environment variable
  /// as a JSON string. Returns an empty map when not set.
  late final Map<String, Map<String, dynamic>> ciergeEventConfig = () {
    final raw = const String.fromEnvironment('WALLET_CONFIG');
    if (raw.isEmpty) return <String, Map<String, dynamic>>{};
    final decoded = _tryJsonDecode(raw);
    if (decoded is! Map) return <String, Map<String, dynamic>>{};
    return decoded.map(
      (k, v) => MapEntry(k as String, Map<String, dynamic>.from(v as Map)),
    );
  }();

  bool get isBiometricsEnabled =>
      const bool.fromEnvironment('BIOMETRICS_ENABLED', defaultValue: true);
  bool get zkpEnabled =>
      const bool.fromEnvironment('ZKP_ENABLED', defaultValue: false);
  bool get audioVideoCallsEnabled => const bool.fromEnvironment(
    'AUDIO_VIDEO_CALLS_ENABLED',
    defaultValue: false,
  );

  bool get personalAiEnabled =>
      const bool.fromEnvironment('PERSONAL_AI_ENABLED', defaultValue: true);

  String get personalAiBaseUrl => const String.fromEnvironment(
    'PERSONAL_AI_BASE_URL',
    defaultValue: 'http://127.0.0.1:8790',
  );

  String get personalAiSetupEndpoint => const String.fromEnvironment(
    'PERSONAL_AI_SETUP_ENDPOINT',
    defaultValue: '/personal-agent/setup',
  );

  String get appVersionName =>
      const String.fromEnvironment('APP_VERSION_NAME', defaultValue: '');

  int get chatActivityExpiresInSeconds => const int.fromEnvironment(
    'CHAT_ACTIVITY_EXPIRES_IN_SECONDS',
    defaultValue: 3,
  );
  int get chatPresenceIntervalInSeconds => const int.fromEnvironment(
    'CHAT_PRESENCE_SEND_INTERVAL_IN_SECONDS',
    defaultValue: 60,
  );

  /// Maximum age, in seconds, at which the original sender can still delete
  /// one of their own messages for everyone. Passed to the chat SDK as
  /// `MeetingPlaceChatSDKOptions.deleteMessageWindow`. Default matches the
  /// SDK default (2 minutes).
  int get deleteMessageWindowInSeconds => const int.fromEnvironment(
    'DELETE_MESSAGE_WINDOW_IN_SECONDS',
    defaultValue: 120,
  );

  int get extraDelayAtLaunchInMilliseconds => const int.fromEnvironment(
    'EXTRA_DELAY_AT_LAUNCH_IN_MILLISECONDS',
    defaultValue: 500,
  );

  /// Maximum size, in bytes, of media retained in the Matrix on-disk cache.
  /// Configured in megabytes via `MATRIX_MEDIA_MAX_CACHE_MB`.
  int get matrixMediaMaxCacheBytes =>
      const int.fromEnvironment('MATRIX_MEDIA_MAX_CACHE_MB', defaultValue: 30) *
      1024 *
      1024;

  /// Maximum size, in bytes, accepted for an outgoing chat attachment such as
  /// a document or video. Configured in megabytes via
  /// `CHAT_ATTACHMENT_MAX_SIZE_MB`.
  int get chatAttachmentMaxBytes =>
      const int.fromEnvironment(
        'CHAT_ATTACHMENT_MAX_SIZE_MB',
        defaultValue: 25,
      ) *
      1024 *
      1024;

  /// Period after which downloaded Matrix media is evicted from the on-disk
  /// cache. Configured in days via `MATRIX_MEDIA_CACHE_TTL_DAYS`.
  Duration get matrixMediaCacheTtl => const Duration(
    days: int.fromEnvironment('MATRIX_MEDIA_CACHE_TTL_DAYS', defaultValue: 30),
  );

  late final Map<String, String> _defaultMediators = Map<String, String>.from(
    jsonDecode(
          const String.fromEnvironment('DEFAULT_MEDIATORS', defaultValue: '{}'),
        )
        as Map<String, dynamic>,
  );
  Map<String, String> get defaultMediators => _defaultMediators;

  List<ChannelTransport> get enabledIndividualChatTransports =>
      _parseEnabledIndividualChatTransports(
        const String.fromEnvironment(
          'ENABLED_INDIVIDUAL_CHAT_TRANSPORTS',
          defaultValue: '["didcomm"]',
        ),
      );

  /// The type to use for direct interactive OOB flows, sourced from the
  /// `DIRECT_INTERACTIVE_OOB_TYPE` compile-time environment variable. If the
  /// variable is not set or is empty, this will return `null`.
  String? get directInteractiveOobType {
    final value = const String.fromEnvironment(
      'DIRECT_INTERACTIVE_OOB_TYPE',
      defaultValue: '',
    );
    return value.isEmpty ? null : value;
  }
}

Provider<Environment> environmentProvider = Provider<Environment>((ref) {
  return Environment.instance;
}, name: 'environmentProvider');

List<ChannelTransport> _parseEnabledIndividualChatTransports(String raw) {
  const fallback = [ChannelTransport.didcomm];
  final decoded = raw.isEmpty ? null : _tryJsonDecode(raw);
  if (decoded is! List) return fallback;

  final transports = decoded
      .whereType<String>()
      .map(
        (token) => ChannelTransport.values.firstWhereOrNull(
          (t) => t.name.toLowerCase() == token.toLowerCase(),
        ),
      )
      .nonNulls
      .toSet()
      .toList();

  return transports.isEmpty ? fallback : transports;
}

Object? _tryJsonDecode(String raw) {
  try {
    return jsonDecode(raw);
  } on FormatException {
    return null;
  }
}
