import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';

import 'fake_publish_offer_result.dart';

class FakeCoreSDKStreamSubscription
    implements CoreSDKStreamSubscription<MediatorMessage> {
  final _controller = StreamController<MediatorMessage>.broadcast();
  bool _isClosed = false;

  void addMessage(dynamic message) {
    if (!_isClosed && message is MediatorMessage) {
      _controller.add(message);
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
    this.offerToFind,
    this.findOfferHasError = false,
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

  int get subscriptionCount => _subscriptions.length;
  final ConnectionOffer? offerToFind;
  final bool findOfferHasError;

  final _controlPlaneEventStreamManager =
      StreamController<ControlPlaneStreamEvent>.broadcast();
  @override
  Stream<ControlPlaneStreamEvent> get controlPlaneEventsStream =>
      _controlPlaneEventStreamManager.stream;

  void simulateIncomingMessage(String channelDid, PlainTextMessage message) {
    final subscription = _subscriptions[channelDid];
    if (subscription != null) {
      subscription.addMessage(message);
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

    if (_publishOfferException != null) {
      throw _publishOfferException;
    }

    if (_offerToReturn != null) {
      return _offerToReturn as PublishOfferResult<T>;
    }

    return FakePublishOfferResult() as PublishOfferResult<T>;
  }

  final List<String> _findOfferCalls = [];
  List<String> get findOfferCalls => _findOfferCalls;

  @override
  Future<FindOfferResult> findOffer({required String mnemonic}) async {
    _findOfferCalls.add(mnemonic);

    return FindOfferResult(
      connectionOffer: offerToFind,
      errorCode: null,
    );
  }

  final List<Map<String, dynamic>> _acceptOfferCalls = [];
  List<Map<String, dynamic>> get acceptOfferCalls => _acceptOfferCalls;

  @override
  Future<AcceptOfferResult<T>> acceptOffer<T extends ConnectionOffer>({
    required T connectionOffer,
    required VCard vCard,
    required String senderInfo,
    String? externalRef,
  }) async {
    _acceptOfferCalls.add({
      'connectionOffer': connectionOffer,
      'vCard': vCard,
      'senderInfo': senderInfo,
      'externalRef': externalRef,
    });

    return _FakeAcceptOfferResult<T>(connectionOffer: connectionOffer);
  }

  @override
  Future<void> processControlPlaneEvents({Function? onDone}) async {
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
    final subscription = FakeCoreSDKStreamSubscription();
    _subscriptions[channelDid] = subscription;
    return subscription;
  }

  @override
  Future<List<MediatorMessage>> fetchMessages({
    required String did,
    String? mediatorDid,
    bool deleteOnRetrieve = false,
    bool deleteFailedMessages = false,
  }) async {
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
    return;
  }

  @override
  Future<Group?> getGroupByOfferLink(String offerLink) async {
    return null;
  }

  @override
  Future<ConnectionOffer?> getConnectionOffer(String offerLink) async {
    return null;
  }

  @override
  Future<Group?> getGroupById(String groupId) async {
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

class _FakeAcceptOfferResult<T extends ConnectionOffer>
    implements AcceptOfferResult<T> {
  _FakeAcceptOfferResult({required this.connectionOffer});

  @override
  final T connectionOffer;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
