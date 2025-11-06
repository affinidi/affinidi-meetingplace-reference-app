import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';

import 'fake_publish_offer_result.dart';

class FakeMeetingPlaceSDK implements MeetingPlaceCoreSDK {
  FakeMeetingPlaceSDK({
    bool shouldFailToRegisterPushToken = false,
    PublishOfferResult? offerToReturn,
    Exception? publishOfferException,
    bool isPhraseAvailable = true,
  })  : _shouldFailToRegisterPushToken = shouldFailToRegisterPushToken,
        _offerToReturn = offerToReturn,
        _publishOfferException = publishOfferException,
        _isPhraseAvailable = isPhraseAvailable;

  final bool _shouldFailToRegisterPushToken;
  final PublishOfferResult? _offerToReturn;
  final Exception? _publishOfferException;
  final bool _isPhraseAvailable;

  final _controlPlaneEventStreamManager =
      StreamController<ControlPlaneStreamEvent>.broadcast();
  @override
  Stream<ControlPlaneStreamEvent> get controlPlaneEventsStream =>
      _controlPlaneEventStreamManager.stream;

  String? _lastRegisteredToken;
  String? get lastRegisteredToken => _lastRegisteredToken;

  int _tokenRegistrationsAttempts = 0;
  int get tokenRegistrationsAttempts => _tokenRegistrationsAttempts;

  @override
  Future<Device> registerForPushNotifications(String deviceToken) async {
    _tokenRegistrationsAttempts += 1;
    if (_shouldFailToRegisterPushToken) {
      throw Exception('Failed to register device token');
    }

    _lastRegisteredToken = deviceToken;
    return Device(
      deviceToken: deviceToken,
      platformType: PlatformType.pushNotification,
    );
  }

  // Track publishOffer calls
  final List<Map<String, dynamic>> _publishOfferCalls = [];
  List<Map<String, dynamic>> get publishOfferCalls => _publishOfferCalls;

  @override
  Future<List<ConnectionOffer>> listConnectionOffers() async {
    return [];
  }

  @override
  Future<ValidateOfferPhraseResult> validateOfferPhrase(String phrase) async {
    return ValidateOfferPhraseResult(isAvailable: _isPhraseAvailable);
  }

  @override
  Future<PublishOfferResult<T>> publishOffer<T extends ConnectionOffer>({
    required String offerName,
    required VCard vCard,
    required SDKConnectionOfferType type,
    required String offerDescription,
    String? customPhrase,
    DateTime? validUntil,
    int? maximumUsage,
    String? mediatorDid,
    String? metadata,
    String? externalRef,
  }) async {
    // Record the call parameters
    _publishOfferCalls.add({
      'offerName': offerName,
      'vCard': vCard.toString(),
      'type': type,
      'offerDescription': offerDescription,
      'customPhrase': customPhrase,
      'validUntil': validUntil,
      'maximumUsage': maximumUsage,
      'mediatorDid': mediatorDid,
      'metadata': metadata,
      'externalRef': externalRef,
    });

    // Check if we should throw an exception
    if (_publishOfferException != null) {
      throw _publishOfferException;
    }

    // Return the specified offer result or default fake result
    if (_offerToReturn != null) {
      return _offerToReturn as PublishOfferResult<T>;
    }

    return FakePublishOfferResult() as PublishOfferResult<T>;
  }

  @override
  Future<void> processControlPlaneEvents({Function? onDone}) async {
    // ignore: avoid_dynamic_calls
    onDone?.call();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
