import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:ssi/ssi.dart';

import 'fake_publish_offer_result.dart';

class FakeMeetingPlaceSDK implements MeetingPlaceMatrixSDK {
  FakeMeetingPlaceSDK({
    this._shouldFailToRegisterPushToken = false,
    this._offerToReturn,
    this._publishOfferException,
    this._createOobFlowException,
    this._acceptOobFlowException,
    this._isPhraseAvailable = true,
    this.isCallSupported = true,
    Map<String, Channel>? channels,
    List<ConnectionOffer>? connectionOffers,
    this.offerToFind,
    this.findOfferHasError = false,
    this._shouldTimeout = false,
    this._options = const MeetingPlaceMatrixSdkOptions(),
  }) : _channels = channels ?? {} {
    if (connectionOffers != null) {
      _allConnectionOffers.addAll(connectionOffers);
    }
  }

  final bool _shouldFailToRegisterPushToken;
  final PublishOfferResult? _offerToReturn;
  final Exception? _publishOfferException;
  final Exception? _createOobFlowException;
  final Exception? _acceptOobFlowException;
  final bool _isPhraseAvailable;
  final bool _shouldTimeout;
  final Map<String, Channel> _channels;
  @override
  final bool isCallSupported;

  final MeetingPlaceMatrixSdkOptions _options;

  @override
  MeetingPlaceMatrixSdkOptions get options => _options;

  final _incomingCallsController =
      StreamController<IncomingAudioVideoCallEvent>.broadcast();
  final _cancelledCallsController =
      StreamController<IncomingAudioVideoCallEvent>.broadcast();
  final _callSignalsController = StreamController<CallSignal>.broadcast();
  final acceptedCallIds = <String>[];
  final declinedCallIds = <String>[];
  int leaveCurrentCallCount = 0;

  DidKeyManager? _fakeDidManager;

  void setFakeDidManager(DidKeyManager manager) {
    _fakeDidManager = manager;
  }

  // Getter to check if subscriptions have been created (useful for debugging)
  final ConnectionOffer? offerToFind;
  final bool findOfferHasError;

  final Completer<void> _controlPlaneEventsListenerCompleter =
      Completer<void>();

  late final StreamController<ControlPlaneStreamEvent>
  _controlPlaneEventStreamManager =
      StreamController<ControlPlaneStreamEvent>.broadcast(
        onListen: () {
          if (!_controlPlaneEventsListenerCompleter.isCompleted) {
            _controlPlaneEventsListenerCompleter.complete();
          }
        },
      );
  @override
  Stream<ControlPlaneStreamEvent> get controlPlaneEventsStream =>
      _controlPlaneEventStreamManager.stream;

  Future<void> waitForControlPlaneEventsListener() =>
      _controlPlaneEventsListenerCompleter.future;

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

  final List<ConnectionOffer> _allConnectionOffers = [];

  void setAllConnectionOffers(List<ConnectionOffer> offers) {
    _allConnectionOffers
      ..clear()
      ..addAll(offers);
  }

  @override
  Future<List<ConnectionOffer>> listConnectionOffers() async {
    return List.unmodifiable(_allConnectionOffers);
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
    ChannelTransport transport = ChannelTransport.didcomm,
    String? contextKey,
    String? customPhrase,
    DateTime? validUntil,
    int? maximumUsage,
    String? mediatorDid,
    String? metadata,
    String? externalRef,
    int? score,
  }) async {
    // Record the call parameters
    _publishOfferCalls.add({
      'offerName': offerName,
      'contactCard': contactCard.toJson(),
      'type': type,
      'offerDescription': offerDescription,
      'contextKey': contextKey,
      'customPhrase': customPhrase,
      'validUntil': validUntil,
      'maximumUsage': maximumUsage,
      'mediatorDid': mediatorDid,
      'metadata': metadata,
      'externalRef': externalRef,
      'score': score,
      'transport': transport,
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
    String? contextKey,
    String? externalRef,
    required String senderInfo,
  }) async {
    _acceptOfferCalls.add({
      'connectionOffer': connectionOffer,
      'contactCard': contactCard.toJson(),
      'contextKey': contextKey,
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
  Future<Channel?> getChannelByDid(String did) async {
    if (_channels.containsKey(did)) return _channels[did];
    for (final channel in _channels.values) {
      if (channel.permanentChannelDid == did ||
          channel.otherPartyPermanentChannelDid == did) {
        return channel;
      }
    }
    return null;
  }

  @override
  Future<DidManager> getDidManager(String did) async {
    if (_fakeDidManager != null) return _fakeDidManager!;
    final wallet = PersistentWallet(InMemoryKeyStore());
    final manager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());
    final keyPair = await wallet.generateKey();
    await manager.addVerificationMethod(keyPair.id);
    _fakeDidManager = manager;
    return manager;
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
  Stream<ChannelAttachmentEvent> get channelAttachments => const Stream.empty();

  @override
  Stream<IncomingAudioVideoCallEvent> get incomingCalls =>
      _incomingCallsController.stream;

  @override
  Stream<IncomingAudioVideoCallEvent> get cancelledCalls =>
      _cancelledCallsController.stream;

  @override
  Stream<CallSignal> get callSignals => _callSignalsController.stream;

  /// Emits a call signal to subscribers, for tests.
  void emitCallSignal(CallSignal signal) => _callSignalsController.add(signal);

  void emitIncomingCall(IncomingAudioVideoCallEvent event) {
    _incomingCallsController.add(event);
  }

  void emitCancelledCall(IncomingAudioVideoCallEvent event) {
    _cancelledCallsController.add(event);
  }

  @override
  Future<void> acceptCall({required String callId}) async {
    acceptedCallIds.add(callId);
  }

  @override
  Future<void> declineCall({required String callId}) async {
    declinedCallIds.add(callId);
  }

  @override
  Future<void> leaveCurrentCall() async {
    leaveCurrentCallCount++;
  }

  @override
  VdipClient get vdip => _fakeVdipClient;

  final _fakeVdipClient = _FakeVdipClient();

  final Map<String, List<ConnectionOffer>> _connectionOffersByExternalRef = {};

  void setConnectionOffersForExternalRef(
    String externalRef,
    List<ConnectionOffer> offers,
  ) {
    _connectionOffersByExternalRef[externalRef] = offers;
  }

  @override
  Future<List<ConnectionOffer>> getConnectionOffersByExternalRef(
    String externalRef,
  ) async {
    return _connectionOffersByExternalRef[externalRef] ?? [];
  }

  final List<Map<String, dynamic>> _updateScoreForOffersCalls = [];
  List<Map<String, dynamic>> get updateScoreForOffersCalls =>
      _updateScoreForOffersCalls;

  @override
  Future<UpdateScoreForOffersResult> updateScoreForOffers({
    required int score,
    required List<ConnectionOffer> offers,
  }) async {
    _updateScoreForOffersCalls.add({'score': score, 'offers': offers});
    return UpdateScoreForOffersResult(
      updatedOffers: offers.map((o) => o.mnemonic).toList(),
      failedOffers: [],
    );
  }

  final List<Map<String, dynamic>> _updateLocalConnectionOffersScoreCalls = [];
  List<Map<String, dynamic>> get updateLocalConnectionOffersScoreCalls =>
      _updateLocalConnectionOffersScoreCalls;

  @override
  Future<void> updateLocalConnectionOffersScore({
    required int score,
    required List<ConnectionOffer> offers,
  }) async {
    _updateLocalConnectionOffersScoreCalls.add({
      'score': score,
      'offers': offers,
    });
  }

  @override
  Future<void> closeVdipStream() async {}

  final List<IncomingMessageSubscription> _subscribeCalls = [];
  List<IncomingMessageSubscription> get subscribeCalls =>
      List.unmodifiable(_subscribeCalls);

  final List<_FakeIncomingMessageHandle> _incomingMessageHandles = [];
  int get activeIncomingMessageSubscriptions =>
      _incomingMessageHandles.where((handle) => !handle.isDisposed).length;

  void simulateIncomingMessage(IncomingMessage message) {
    for (final handle in _incomingMessageHandles) {
      handle.add(message);
    }
  }

  @override
  Future<IncomingMessageHandle> subscribe(
    IncomingMessageSubscription subscription,
  ) async {
    _subscribeCalls.add(subscription);

    late final _FakeIncomingMessageHandle handle;
    handle = _FakeIncomingMessageHandle(
      onDispose: () {
        _incomingMessageHandles.removeWhere(
          (existingHandle) => identical(existingHandle, handle),
        );
      },
    );
    _incomingMessageHandles.add(handle);
    return handle;
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

class _FakeVdipClient implements VdipClient {
  final List<Future<void> Function(PlainTextMessage)> _messageProcessors = [];
  final List<Map<String, dynamic>> sendIssuedCredentialCalls = [];

  @override
  Stream<PlainTextMessage> get incomingMessages => const Stream.empty();

  @override
  List<Future<void> Function(PlainTextMessage)> get messageProcessors =>
      List.unmodifiable(_messageProcessors);

  @override
  void registerMessageProcessor(
    Future<void> Function(PlainTextMessage) processor,
  ) {
    _messageProcessors.add(processor);
  }

  @override
  Future<void> issueCredential({
    required Channel channel,
    required VerifiableCredential credential,
  }) async {
    // no-op: credential issuance is not tested at the network level
  }

  @override
  Future<void> sendIssuedCredential({
    required String senderDid,
    required String recipientDid,
    required VdipIssuedCredentialBody body,
  }) async {
    sendIssuedCredentialCalls.add({
      'senderDid': senderDid,
      'recipientDid': recipientDid,
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeIncomingMessageHandle implements IncomingMessageHandle {
  _FakeIncomingMessageHandle({required this.onDispose});

  final void Function() onDispose;
  final StreamController<IncomingMessage> _streamController =
      StreamController<IncomingMessage>.broadcast();

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  Stream<IncomingMessage> get stream => _streamController.stream;

  void add(IncomingMessage message) {
    if (_isDisposed || _streamController.isClosed) {
      return;
    }

    _streamController.add(message);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    await _streamController.close();
    onDispose();
  }
}
