import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';

import 'fake_publish_offer_result.dart';

class FakeCoreSDKStreamSubscription
    implements CoreSDKStreamSubscription<MediatorMessage> {
  final _controller = StreamController<MediatorMessage>.broadcast();
  bool _isClosed = false;

  // Allow external code to add messages to the stream
  // Accept dynamic to allow both MediatorMessage and its subtypes like PlainTextMessage
  void addMessage(dynamic message) {
    if (!_isClosed && message is MediatorMessage) {
      // ignore: avoid_print
      print(
          'DEBUG addMessage: Adding message to stream. hasListener=${_controller.hasListener}');
      _controller.add(message);
      // ignore: avoid_print
      print('DEBUG addMessage: Message added to stream');
    }
  }

  @override
  Stream<MediatorMessage> get stream => _controller.stream;

  @override
  bool get isClosed => _isClosed;

  @override
  StreamSubscription<MediatorMessage> listen(
    void Function(MediatorMessage)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // ignore: avoid_print
    print(
        'DEBUG FakeCoreSDKStreamSubscription.listen: Someone is listening to the stream');
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  StreamSubscription<MediatorMessage> timeout(
    Duration duration, [
    void Function()? onTimeout,
  ]) {
    // Return the stream subscription directly
    return _controller.stream.listen(null);
  }

  @override
  Future<void> dispose() async {
    _isClosed = true;
    await _controller.close();
  }
}

class FakeMeetingPlaceSDK implements MeetingPlaceCoreSDK {
  FakeMeetingPlaceSDK({
    bool shouldFailToRegisterPushToken = false,
    PublishOfferResult? offerToReturn,
    Exception? publishOfferException,
    bool isPhraseAvailable = true,
    Map<String, Channel>? channels,
  })  : _shouldFailToRegisterPushToken = shouldFailToRegisterPushToken,
        _offerToReturn = offerToReturn,
        _publishOfferException = publishOfferException,
        _isPhraseAvailable = isPhraseAvailable,
        _channels = channels ?? {};

  final bool _shouldFailToRegisterPushToken;
  final PublishOfferResult? _offerToReturn;
  final Exception? _publishOfferException;
  final bool _isPhraseAvailable;
  final Map<String, Channel> _channels;
  final Map<String, FakeCoreSDKStreamSubscription> _subscriptions = {};

  // Getter to check if subscriptions have been created (useful for debugging)
  int get subscriptionCount => _subscriptions.length;

  final _controlPlaneEventStreamManager =
      StreamController<ControlPlaneStreamEvent>.broadcast();
  @override
  Stream<ControlPlaneStreamEvent> get controlPlaneEventsStream =>
      _controlPlaneEventStreamManager.stream;

  // Allow tests to simulate receiving messages
  // PlainTextMessage extends MediatorMessage so we can accept it and add it to the stream
  void simulateIncomingMessage(String channelDid, PlainTextMessage message) {
    final subscription = _subscriptions[channelDid];
    // ignore: avoid_print
    print(
        'DEBUG simulateIncomingMessage: channelDid=$channelDid, subscription=${subscription != null ? "exists" : "null"}');
    if (subscription != null) {
      // PlainTextMessage is a subtype of MediatorMessage
      subscription.addMessage(message);
      // ignore: avoid_print
      print('DEBUG: Message added to subscription stream');
    }
  }

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
  Future<Channel?> getChannelByOtherPartyPermanentDid(String channelDid) async {
    final channel = _channels[channelDid];
    return channel;
  }

  @override
  Future<CoreSDKStreamSubscription<MediatorMessage>> subscribeToMediator(
    String channelDid, {
    String? mediatorDid,
  }) async {
    // ignore: avoid_print
    print('DEBUG subscribeToMediator: channelDid=$channelDid');
    // Create and store a subscription for this channel
    final subscription = FakeCoreSDKStreamSubscription();
    _subscriptions[channelDid] = subscription;
    // ignore: avoid_print
    print(
        'DEBUG: Subscription created. Total subscriptions: ${_subscriptions.length}');
    return subscription;
  }

  @override
  Future<List<MediatorMessage>> fetchMessages({
    required String did,
    String? mediatorDid,
    bool deleteOnRetrieve = false,
    bool deleteFailedMessages = false,
  }) async {
    // Return empty list - no messages in fake
    return [];
  }

  @override
  Future<void> sendMessage(
    PlainTextMessage message, {
    required String senderDid,
    required String recipientDid,
    String? mediatorDid,
    bool? ephemeral,
    int? forwardExpiryInSeconds,
    String? notifyChannelType,
  }) async {
    // Fake implementation - just return successfully
    return;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
