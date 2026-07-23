import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/firebase_environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/image_config.dart';

import 'fake_mediators.dart';

class FakeEnvironment implements Environment {
  FakeEnvironment({
    this.controlPlaneDid = 'did:test:control-plane',
    this.matrixHomeserver = 'https://test-matrix.org',
    String? defaultMediatorDid,
    this.maxOfferUsages = 100,
    this.personalAiEnabled = false,
    this.personalAiBaseUrl = 'http://127.0.0.1:8790',
    this.personalAiSetupEndpoint = '/personal-agent/setup',
    this.vtaBaseUrl = '',
    this.vtaDid = '',
    this.vtaMediatorUrl = '',
    this.vtaMediatorDid = '',
    this._defaultMediators = const {},
    this.enabledIndividualChatTransports = const [
      ChannelTransport.didcomm,
      ChannelTransport.matrix,
    ],
    this.audioVideoCallsEnabled = false,
  }) : defaultMediatorDid =
           defaultMediatorDid ?? FakeMediators.defaultMediator.mediatorDid;

  final Map<String, String> _defaultMediators;
  @override
  Map<String, String> get defaultMediators => _defaultMediators;

  @override
  final String controlPlaneDid;

  @override
  final String defaultMediatorDid;

  @override
  final String matrixHomeserver;

  @override
  final int maxOfferUsages;

  @override
  final bool personalAiEnabled;

  @override
  final String personalAiBaseUrl;

  @override
  final String personalAiSetupEndpoint;

  @override
  final List<ChannelTransport> enabledIndividualChatTransports;

  @override
  String get microsoftOAuthTenantId => 'common';

  @override
  String get microsoftOAuthClientId => 'test-client-id';

  @override
  String get microsoftOAuthRedirectUrl => 'mpx://auth/microsoft/callback';

  @override
  int get maxLogMemoryEntries => 1000;

  @override
  FirebaseEnvironment get firebase => FirebaseEnvironment.instance;

  @override
  Duration get minimumExpiryOffset => const Duration(minutes: 5);

  @override
  Duration get defaultExpiryOffset => const Duration(days: 7);

  @override
  Duration get maximumExpiryOffset => const Duration(days: 365);

  @override
  Duration get inputDebounceDuration => const Duration(milliseconds: 800);

  @override
  Duration get initialTimeOffset => const Duration(minutes: 3);

  @override
  int get numberOfTapsToUnlockDebug => 7;

  @override
  bool get isDatabaseLoggingEnabled => false;

  @override
  bool get isForegroundNotificationsEnabled => false;

  @override
  String get marketplaceQrPrefix => 'test-marketplace-qr';

  @override
  ImageConfig get chatImageConfig =>
      ImageConfig(qualityPercentage: 80, imageMaxSize: 800);

  @override
  ImageConfig get profileImageConfig =>
      ImageConfig(qualityPercentage: 80, imageMaxSize: 100);

  @override
  bool get isBiometricsEnabled => true;

  @override
  bool get zkpEnabled => false;

  @override
  final bool audioVideoCallsEnabled;

  @override
  String get appVersionName => '1.0.0-test';

  @override
  int get chatActivityExpiresInSeconds => 3;

  @override
  int get chatPresenceIntervalInSeconds => 60;

  @override
  int get deleteMessageWindowInSeconds => 120;

  @override
  int get extraDelayAtLaunchInMilliseconds => 0;

  @override
  int get matrixMediaMaxCacheBytes => 30 * 1024 * 1024;

  @override
  int get chatAttachmentMaxBytes => 25 * 1024 * 1024;

  @override
  Duration get matrixMediaCacheTtl => const Duration(days: 30);

  @override
  String? get directInteractiveOobType => null;

  @override
  String get livekitServiceUrl => '';

  @override
  String get livekitSfuUrl => '';

  @override
  String get matrixServerName => Uri.parse(matrixHomeserver).host;

  @override
  Duration get callRingTimeout => const Duration(seconds: 60);

  @override
  Map<String, Map<String, dynamic>> get ciergeEventConfig => const {};

  @override
  final String vtaBaseUrl;

  @override
  final String vtaDid;

  @override
  final String vtaMediatorUrl;

  @override
  final String vtaMediatorDid;
}
