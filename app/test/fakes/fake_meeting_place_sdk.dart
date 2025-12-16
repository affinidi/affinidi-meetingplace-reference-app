import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_core/src/sdk/results/accept_oob_flow_result.dart';
import 'package:meeting_place_core/src/sdk/results/create_oob_flow_result.dart';
import 'package:meeting_place_core/src/service/oob/oob_stream.dart';

import 'fake_publish_offer_result.dart';

class FakeMeetingPlaceSDK implements MeetingPlaceCoreSDK {
  FakeMeetingPlaceSDK({
    bool shouldFailToRegisterPushToken = false,
    PublishOfferResult? offerToReturn,
    Exception? publishOfferException,
    Exception? createOobFlowException,
    bool isPhraseAvailable = true,
    Map<String, Channel>? channels,
    this.offerToFind,
    this.findOfferHasError = false,
  })  : _shouldFailToRegisterPushToken = shouldFailToRegisterPushToken,
        _offerToReturn = offerToReturn,
        _publishOfferException = publishOfferException,
        _createOobFlowException = createOobFlowException,
        _isPhraseAvailable = isPhraseAvailable,
        _channels = channels ?? {};

  final bool _shouldFailToRegisterPushToken;
  final PublishOfferResult? _offerToReturn;
  final Exception? _publishOfferException;
  final Exception? _createOobFlowException;
  final bool _isPhraseAvailable;
  final Map<String, Channel> _channels;

  // Getter to check if subscriptions have been created (useful for debugging)
  final ConnectionOffer? offerToFind;
  final bool findOfferHasError;

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
    required ContactCard contactCard,
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

  StreamController<OobStreamData>? _createOobStreamController;
  StreamController<OobStreamData>? _acceptOobStreamController;

  final List<Map<String, dynamic>> _createOobFlowCalls = [];
  List<Map<String, dynamic>> get createOobFlowCalls => _createOobFlowCalls;

  final List<Map<String, dynamic>> _acceptOobFlowCalls = [];
  List<Map<String, dynamic>> get acceptOobFlowCalls => _acceptOobFlowCalls;

  /// Simulates a successful OOB connection by emitting channel data
  /// through the create OOB flow stream
  void simulateOobConnectionEstablished(Channel channel) {
    _createOobStreamController?.add(OobStreamData(
      eventType: EventType.connectionSetup,
      message: PlainTextMessage.fromJson({
        'id': 'fake-message-id',
        'type': 'fake-type',
        'from': channel.publishOfferDid,
        'to': [channel.acceptOfferDid],
      }),
      channel: channel,
    ));
  }

  /// Simulates a successful OOB connection by emitting channel data
  /// through the accept OOB flow stream
  void simulateOobAcceptConnectionEstablished(Channel channel) {
    _acceptOobStreamController?.add(OobStreamData(
      eventType: EventType.connectionAccepted,
      message: PlainTextMessage.fromJson({
        'id': 'fake-message-id',
        'type': 'fake-type',
        'from': channel.acceptOfferDid,
        'to': [channel.publishOfferDid],
      }),
      channel: channel,
    ));
  }

  @override
  Future<CreateOobFlowResult> createOobFlow({
    String? did,
    required VCard vCard,
    String? mediatorDid,
    String? externalRef,
  }) async {
    _createOobFlowCalls.add({
      'did': did,
      'vCard': vCard,
      'mediatorDid': mediatorDid,
      'externalRef': externalRef,
    });

    if (_createOobFlowException != null) {
      throw _createOobFlowException;
    }

    final oobUrl = Uri.parse('https://example.com/oob?_oob=fake-oob-token');
    _createOobStreamController = StreamController<OobStreamData>.broadcast();

    return _FakeCreateOobFlowResult(
      oobUrl: oobUrl,
      streamSubscription: _FakeCoreSDKStreamSubscription(
        stream: _createOobStreamController!.stream,
        onDispose: () async {
          await _createOobStreamController?.close();
          _createOobStreamController = null;
        },
      ),
    );
  }

  @override
  Future<AcceptOobFlowResult> acceptOobFlow(
    Uri oobUri, {
    required VCard vCard,
    String? externalRef,
  }) async {
    _acceptOobFlowCalls.add({
      'oobUri': oobUri,
      'vCard': vCard,
      'externalRef': externalRef,
    });

    _acceptOobStreamController = StreamController<OobStreamData>.broadcast();

    final fakeChannel = Channel(
      offerLink: 'fake-offer-link',
      publishOfferDid: 'fake-publish-did',
      mediatorDid: 'fake-mediator-did',
      status: ChannelStatus.waitingForApproval,
      outboundMessageId: 'fake-message-id',
      acceptOfferDid: 'fake-accept-did',
      permanentChannelDid: 'fake-permanent-did',
      type: ChannelType.oob,
      vCard: vCard,
      externalRef: externalRef,
    );

    return _FakeAcceptOobFlowResult(
      // streamSubscription: _FakeCoreSDKStreamSubscription(
      //   stream: _acceptOobStreamController!.stream,
      //   onDispose: () async {
      //     await _acceptOobStreamController?.close();
      //     _acceptOobStreamController = null;
      //   },
      // ),
      channel: fakeChannel,
    );
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

class _FakeCreateOobFlowResult implements CreateOobFlowResult {
  _FakeCreateOobFlowResult({
    required this.oobUrl,
    required this.streamSubscription,
  });

  @override
  final Uri oobUrl;

  @override
  final CoreSDKStreamSubscription<OobStreamData> streamSubscription;
}

class _FakeAcceptOobFlowResult implements AcceptOobFlowResult {
  _FakeAcceptOobFlowResult({
    required this.channel,
  });

  @override
  final Channel channel;

  @override
  OobStream get streamSubscription => throw UnimplementedError();
}

class _FakeCoreSDKStreamSubscription<T>
    implements CoreSDKStreamSubscription<T> {
  _FakeCoreSDKStreamSubscription({
    required this.stream,
    required this.onDispose,
  });

  @override
  final Stream<T> stream;

  final Future<void> Function() onDispose;

  bool _isClosed = false;

  @override
  bool get isClosed => _isClosed;

  @override
  Future<void> dispose() async {
    _isClosed = true;
    await onDispose();
  }

  @override
  StreamSubscription<T> listen(
    void Function(T data) onData, {
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
  StreamSubscription<T> timeout(Duration duration, void Function()? onTimeout) {
    // No-op for fake - just return a no-op subscription
    return stream.listen((_) {});
  }
}
