import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:ssi/src/did/did_document/did_document.dart';

import 'fake_publish_offer_result.dart';

class FakeMeetingPlaceSDK implements MeetingPlaceCoreSDK {
  FakeMeetingPlaceSDK({
    bool shouldFailToRegisterPushToken = false,
    PublishOfferResult? offerToReturn,
    Exception? publishOfferException,
    Exception? createOobFlowException,
    Exception? acceptOobFlowException,
    bool isPhraseAvailable = true,
    Map<String, Channel>? channels,
    List<ConnectionOffer>? connectionOffers,
    this.offerToFind,
    this.findOfferHasError = false,
    bool shouldTimeout = false,
    this.shouldFailToLeaveChannel = false,
  }) : _shouldFailToRegisterPushToken = shouldFailToRegisterPushToken,
       _offerToReturn = offerToReturn,
       _publishOfferException = publishOfferException,
       _createOobFlowException = createOobFlowException,
       _acceptOobFlowException = acceptOobFlowException,
       _isPhraseAvailable = isPhraseAvailable,
       _shouldTimeout = shouldTimeout,
       _channels = channels ?? {},
       _connectionOffers = connectionOffers ?? [];

  final bool _shouldFailToRegisterPushToken;
  final PublishOfferResult? _offerToReturn;
  final Exception? _publishOfferException;
  final Exception? _createOobFlowException;
  final Exception? _acceptOobFlowException;
  final bool _isPhraseAvailable;
  final bool _shouldTimeout;
  final Map<String, Channel> _channels;
  final List<ConnectionOffer> _connectionOffers;

  // Getter to check if subscriptions have been created (useful for debugging)
  final ConnectionOffer? offerToFind;
  final bool findOfferHasError;
  final bool shouldFailToLeaveChannel;

  final _controlPlaneEventStreamManager =
      StreamController<ControlPlaneStreamEvent>.broadcast();
  @override
  Stream<ControlPlaneStreamEvent> get controlPlaneEventsStream =>
      _controlPlaneEventStreamManager.stream;

  String? _lastRegisteredToken;
  String? get lastRegisteredToken => _lastRegisteredToken;

  int _tokenRegistrationsAttempts = 0;
  int get tokenRegistrationsAttempts => _tokenRegistrationsAttempts;

  Group? _mockGroup;

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
    return _connectionOffers;
  }

  @override
  Future<ValidateOfferPhraseResult> validateOfferPhrase(String phrase) async {
    return ValidateOfferPhraseResult(isAvailable: _isPhraseAvailable);
  }

  @override
  Future<PublishOfferResult<T>> publishOffer<T extends ConnectionOffer>({
    required String offerName,
    required ContactCard contactCard,
    required SDKConnectionOfferType type,
    required String offerDescription,
    String? customPhrase,
    DateTime? validUntil,
    int? maximumUsage,
    String? mediatorDid,
    String? metadata,
    String? externalRef,
    ChannelTransport transport = ChannelTransport.didcomm,
  }) async {
    // Record the call parameters
    _publishOfferCalls.add({
      'offerName': offerName,
      'contactCard': contactCard.toJson(),
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

    return FindOfferResult(connectionOffer: offerToFind, errorCode: null);
  }

  final List<Map<String, dynamic>> _acceptOfferCalls = [];
  List<Map<String, dynamic>> get acceptOfferCalls => _acceptOfferCalls;

  @override
  Future<AcceptOfferResult<T>> acceptOffer<T extends ConnectionOffer>({
    required T connectionOffer,
    required ContactCard contactCard,
    String? senderInfo,
    String? externalRef,
  }) async {
    _acceptOfferCalls.add({
      'connectionOffer': connectionOffer,
      'contactCard': contactCard.toJson(),
      'senderInfo': senderInfo,
      'externalRef': externalRef,
    });

    return _FakeAcceptOfferResult<T>(connectionOffer: connectionOffer);
  }

  @override
  Future<void> processControlPlaneEvents({
    void Function(List<Object> errors)? onDone,
  }) async {
    // ignore: avoid_dynamic_calls
    onDone?.call([]);
  }

  @override
  Future<Channel?> getChannelByOtherPartyPermanentDid(String channelDid) async {
    final channel = _channels[channelDid];
    return channel;
  }

  @override
  Future<void> leaveChannel(Channel channel) async {
    if (shouldFailToLeaveChannel) {
      throw Exception('Simulated leaveChannel error');
    }
  }

  @override
  Future<Group?> getGroupByOfferLink(String offerLink) async {
    return _mockGroup;
  }

  @override
  Future<ConnectionOffer?> getConnectionOffer(String offerLink) async {
    return null;
  }

  @override
  Future<Group?> getGroupById(String groupId) async {
    if (_mockGroup != null && _mockGroup!.id == groupId) {
      return _mockGroup;
    }
    return null;
  }

  OobStream? _createOobStream;
  OobStream? _acceptOobStream;

  final List<Map<String, dynamic>> _createOobFlowCalls = [];
  List<Map<String, dynamic>> get createOobFlowCalls => _createOobFlowCalls;

  final List<Map<String, dynamic>> _acceptOobFlowCalls = [];
  List<Map<String, dynamic>> get acceptOobFlowCalls => _acceptOobFlowCalls;

  final List<String> _acceptOobStreamDisposals = [];
  List<String> get acceptOobStreamDisposals => _acceptOobStreamDisposals;

  final List<String> _createOobStreamDisposals = [];
  List<String> get createOobStreamDisposals => _createOobStreamDisposals;

  /// Simulates a successful OOB connection by emitting channel data
  /// through the create OOB flow stream
  void simulateOobConnectionEstablished(Channel channel) {
    _createOobStream?.pushEvent(
      OobStreamData(
        eventType: EventType.connectionSetup,
        message: PlainTextMessage.fromJson({
          'id': 'fake-message-id',
          'type': 'fake-type',
          'from': channel.publishOfferDid,
          'to': [channel.acceptOfferDid],
        }),
        channel: channel,
      ),
    );
  }

  /// Simulates a successful OOB connection by emitting channel data
  /// through the accept OOB flow stream
  void simulateOobAcceptConnectionEstablished(Channel channel) {
    _acceptOobStream?.pushEvent(
      OobStreamData(
        eventType: EventType.connectionAccepted,
        message: PlainTextMessage.fromJson({
          'id': 'fake-message-id',
          'type': 'fake-type',
          'from': channel.acceptOfferDid,
          'to': [channel.publishOfferDid],
        }),
        channel: channel,
      ),
    );
  }

  /// Simulates a QR code scan by calling acceptOobFlow with test data
  void simulateQrScan(String qrData) {
    // In a real scenario, the QR scanner would trigger the acceptOobFlow
    // For testing, we just track that a scan occurred
    // The actual acceptOobFlow call will be made by the controller
  }

  @override
  Future<OobOfferSession> createOobFlow({
    String? did,
    required ContactCard contactCard,
    String? mediatorDid,
    String? externalRef,
    String? type,
  }) async {
    _createOobFlowCalls.add({
      'did': did,
      'contactCard': contactCard,
      'mediatorDid': mediatorDid,
      'externalRef': externalRef,
      'type': type,
    });

    if (_createOobFlowException != null) {
      throw _createOobFlowException;
    }

    final oobUri = Uri.parse('https://example.com/oob?_oob=fake-oob-token');
    _createOobStream = _FakeOobStream(
      onDispose: () async {
        _createOobStreamDisposals.add(oobUri.toString());
      },
      shouldTimeout: _shouldTimeout,
    );

    return _FakeOobOfferSession(oobUrl: oobUri, stream: _createOobStream!);
  }

  @override
  Future<OobAcceptanceSession> acceptOobFlow(
    Uri oobUri, {
    List<Attachment>? attachments,
    required ContactCard contactCard,
    String? did,
    String? externalRef,
    String? type,
  }) async {
    _acceptOobFlowCalls.add({
      'offerLink': oobUri.toString(),
      'oobUri': oobUri,
      'contactCard': contactCard,
      'did': did,
      'externalRef': externalRef,
    });

    if (_acceptOobFlowException != null) {
      throw _acceptOobFlowException;
    }

    _acceptOobStream = _FakeOobStream(
      onDispose: () async {
        _acceptOobStreamDisposals.add(oobUri.toString());
      },
      shouldTimeout: _shouldTimeout,
    );

    final fakeChannel = Channel(
      offerLink: 'fake-offer-link',
      publishOfferDid: 'fake-publish-did',
      mediatorDid: 'fake-mediator-did',
      status: ChannelStatus.waitingForApproval,
      outboundMessageId: 'fake-message-id',
      acceptOfferDid: 'fake-accept-did',
      permanentChannelDid: 'fake-permanent-did',
      type: ChannelType.oob,
      contactCard: contactCard,
      externalRef: externalRef,
      isConnectionInitiator: false,
    );

    _acceptOobFlowCalls.last['channel'] = fakeChannel;

    return _FakeOobAcceptanceSession(
      stream: _acceptOobStream!,
      channel: fakeChannel,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }

  void simulateChannelActivity(Channel channel) {
    _controlPlaneEventStreamManager.add(
      ControlPlaneStreamEvent(
        type: ControlPlaneEventType.ChannelActivity,
        channel: channel,
      ),
    );
  }

  void setMockGroup(Group group) {
    _mockGroup = group;
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

class _FakeOobOfferSession implements OobOfferSession {
  _FakeOobOfferSession({required this.oobUrl, required this.stream});

  @override
  final Uri oobUrl;

  @override
  final OobStream stream;

  @override
  ContactCard get contactCard => throw UnimplementedError();

  @override
  DidDocument get didDocument => throw UnimplementedError();

  @override
  DidManager get didManager => throw UnimplementedError();

  @override
  String get mediatorDid => throw UnimplementedError();

  @override
  OobInvitationMessage get oobInvitationMessage => throw UnimplementedError();
}

class _FakeOobAcceptanceSession implements OobAcceptanceSession {
  _FakeOobAcceptanceSession({required this.channel, required this.stream});

  @override
  final Channel channel;

  @override
  final OobStream stream;

  @override
  String get mediatorDid => throw UnimplementedError();

  @override
  DidDocument get permanentChannelDidDocument => throw UnimplementedError();

  @override
  DidManager get permanentChannelDidManager => throw UnimplementedError();
}

class _FakeOobStream implements OobStream {
  _FakeOobStream({required this.onDispose, this.shouldTimeout = false});

  final StreamController<OobStreamData> _streamController =
      StreamController<OobStreamData>.broadcast();

  @override
  Stream<OobStreamData> get stream => _streamController.stream;

  final Future<void> Function() onDispose;
  final bool shouldTimeout;
  void Function()? _timeoutCallback;

  @override
  bool get isClosed => _streamController.isClosed;

  @override
  Future<void> dispose() async {
    await _streamController.close();

    await onDispose();
  }

  @override
  StreamSubscription<OobStreamData> listen(
    void Function(OobStreamData data) onData, {
    bool? cancelOnError,
    void Function()? onDone,
    Function? onError,
  }) {
    return stream.listen(
      onData,
      cancelOnError: cancelOnError,
      onDone: onDone,
      onError: onError,
    );
  }

  @override
  StreamSubscription<OobStreamData> timeout(
    Duration duration,
    void Function()? onTimeout,
  ) {
    _timeoutCallback = onTimeout;
    if (shouldTimeout && onTimeout != null) {
      // Trigger timeout immediately in test
      Future.microtask(() => onTimeout());
    }
    return stream.listen((_) {});
  }

  @override
  void pushEvent(OobStreamData event) {
    _streamController.add(event);
  }

  void triggerTimeout() {
    _timeoutCallback?.call();
  }
}
