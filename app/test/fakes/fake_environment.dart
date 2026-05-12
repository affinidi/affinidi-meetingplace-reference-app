import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/firebase_environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/image_config.dart';

import 'fake_mediators.dart';

class FakeEnvironment implements Environment {
  FakeEnvironment({
    this.controlPlaneDid = 'did:test:control-plane',
    String? defaultMediatorDid,
    this.maxOfferUsages = 100,
    Map<String, String> defaultMediators = const {},
  }) : _defaultMediators = defaultMediators,
       defaultMediatorDid =
           defaultMediatorDid ?? FakeMediators.defaultMediator.mediatorDid;

  final Map<String, String> _defaultMediators;
  @override
  Map<String, String> get defaultMediators => _defaultMediators;

  @override
  final String controlPlaneDid;

  @override
  final String defaultMediatorDid;

  @override
  final int maxOfferUsages;

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
  String get appVersionName => '1.0.0-test';

  @override
  int get chatActivityExpiresInSeconds => 3;

  @override
  int get chatPresenceIntervalInSeconds => 60;

  @override
  int get extraDelayAtLaunchInMilliseconds => 0;

  @override
  String? get directInteractiveOobType => null;
}
