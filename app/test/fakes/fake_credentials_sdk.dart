import 'dart:async';
import 'dart:convert';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/vdip_manager.dart'
    show VdipManager;

import 'fake_meeting_place_sdk.dart';
import 'fake_r_card_repository.dart';
import 'fake_vrc_repository.dart';

class StubCredentialsSdk extends MeetingPlaceCredentialsSDK {
  StubCredentialsSdk({
    required super.coreSDK,
    required super.rCardRepository,
    required super.vrcRepository,
    required VrcIssuance this._pendingVrc,
  });

  VrcIssuance? _pendingVrc;

  @override
  VrcIssuance? consumePendingVrc(String senderDid) {
    final vrc = _pendingVrc;
    _pendingVrc = null;
    return vrc;
  }

  @override
  RCard? consumePendingRCard(String senderDid) => null;
}

/// A controllable [MeetingPlaceCredentialsSDK] stub for [VdipManager] tests.
/// Supports broadcasting events via [emitRequest]/[emitVrc] and configuring
/// the processing results returned by [handleReceivedVrcRequest] and
/// [handleReceivedVrc].
class StubVdipCredentialsSdk extends MeetingPlaceCredentialsSDK {
  StubVdipCredentialsSdk({
    required super.coreSDK,
    required super.rCardRepository,
    required super.vrcRepository,
  });

  final _requestCtrl = StreamController<VrcRequest>.broadcast(sync: true);
  final _vrcCtrl = StreamController<VrcIssuance>.broadcast(sync: true);
  final List<Completer<void>> _pendingRequestHandlers = [];
  final List<Completer<void>> _pendingVrcHandlers = [];

  int activeRequestListenerCount = 0;
  int activeVrcListenerCount = 0;

  VrcRequest? pendingRequest;
  VrcIssuance? pendingVrc;
  final List<VrcExchangeState> handledVrcExchangeStates = [];
  Completer<void>? firstVrcHandlerStarted;
  Completer<void>? allowFirstVrcHandlerToContinue;

  VrcRequestProcessingResult nextRequestResult =
      const VrcRequestProcessingResultPromptRequired();
  VrcProcessingResult nextVrcResult = const VrcProcessingResultIgnored();

  @override
  Stream<VrcRequest> get receivedVrcRequests => _TrackableStream<VrcRequest>(
    _requestCtrl.stream,
    onListen: () => activeRequestListenerCount += 1,
    onCancel: () => activeRequestListenerCount -= 1,
  );

  @override
  Stream<VrcIssuance> get receivedVrcs => _TrackableStream<VrcIssuance>(
    _vrcCtrl.stream,
    onListen: () => activeVrcListenerCount += 1,
    onCancel: () => activeVrcListenerCount -= 1,
  );

  @override
  VrcRequest? consumePendingVrcRequest(String senderDid) {
    final r = pendingRequest;
    pendingRequest = null;
    return r;
  }

  @override
  VrcIssuance? consumePendingVrc(String senderDid) {
    final v = pendingVrc;
    pendingVrc = null;
    return v;
  }

  @override
  RCard? consumePendingRCard(String senderDid) => null;

  @override
  Future<VrcRequestProcessingResult> handleReceivedVrcRequest({
    required String permanentChannelDid,
    required VrcRequest request,
    required bool hasVrcExchangeInitiated,
    required bool isConnectionInitiator,
    String? issuerDid,
    String? issuerName,
  }) async {
    try {
      return nextRequestResult;
    } finally {
      _completeNextPendingHandler(_pendingRequestHandlers);
    }
  }

  @override
  Future<VrcProcessingResult> handleReceivedVrc({
    required String permanentChannelDid,
    required String vcBlob,
    required VrcExchangeState exchangeState,
    String? issuerDid,
    String? issuerName,
  }) async {
    try {
      handledVrcExchangeStates.add(exchangeState);
      if (handledVrcExchangeStates.length == 1) {
        firstVrcHandlerStarted?.complete();
        await allowFirstVrcHandlerToContinue?.future;
      }
      return nextVrcResult;
    } finally {
      _completeNextPendingHandler(_pendingVrcHandlers);
    }
  }

  void emitRequest(VrcRequest r) => _requestCtrl.add(r);
  void emitVrc(VrcIssuance v) => _vrcCtrl.add(v);

  Future<void> emitRequestAndWaitHandled(VrcRequest request) {
    final completer = Completer<void>();
    _pendingRequestHandlers.add(completer);
    _requestCtrl.add(request);
    return completer.future;
  }

  Future<void> emitVrcAndWaitHandled(VrcIssuance issuance) {
    final completer = Completer<void>();
    _pendingVrcHandlers.add(completer);
    _vrcCtrl.add(issuance);
    return completer.future;
  }

  void _completeNextPendingHandler(List<Completer<void>> pendingHandlers) {
    if (pendingHandlers.isEmpty) return;
    pendingHandlers.removeAt(0).complete();
  }

  Future<void> dispose() async {
    await _requestCtrl.close();
    await _vrcCtrl.close();
    await closeCredentialStreams();
  }
}

/// A controllable [MeetingPlaceCredentialsSDK] stub for RCardManager tests.
/// Supports broadcasting events via [emitRCard] and configuring the [RCard]
/// returned by [sendRCard].
class StubRCardCredentialsSdk extends MeetingPlaceCredentialsSDK {
  StubRCardCredentialsSdk({
    required super.coreSDK,
    required super.rCardRepository,
    required super.vrcRepository,
  });

  final _rCardsCtrl = StreamController<RCard>.broadcast();
  final List<Completer<void>> _pendingRCardDeliveries = [];

  RCard? pendingRCard;

  @override
  Stream<RCard> get receivedRCards => _AwaitableBroadcastStream<RCard>(
    _rCardsCtrl.stream,
    onDataHandled: _completeNextPendingRCardDelivery,
  );

  @override
  RCard? consumePendingRCard(String senderDid) {
    final r = pendingRCard;
    pendingRCard = null;
    return r;
  }

  @override
  Future<RCard> sendRCard({
    required Channel channel,
    required String subjectDid,
    required RCardSubject card,
    required DidManager issuerDidManager,
  }) async {
    return RCard(
      subjectDid: subjectDid,
      vcBlob: jsonEncode({
        'id': 'urn:stub-rcard',
        'type': ['VerifiableCredential'],
      }),
      issuerDid: channel.permanentChannelDid ?? 'did:key:issuer',
      version: RCardConstants.receivedRCardVersion,
      issuanceDate: DateTime.now(),
      receivedAt: DateTime.now(),
    );
  }

  void emitRCard(RCard rCard) => _rCardsCtrl.add(rCard);

  Future<void> emitRCardAndWait(RCard rCard) {
    final completer = Completer<void>();
    _pendingRCardDeliveries.add(completer);
    _rCardsCtrl.add(rCard);
    return completer.future;
  }

  void _completeNextPendingRCardDelivery(Future<void>? delivery) {
    if (_pendingRCardDeliveries.isEmpty) return;

    final completer = _pendingRCardDeliveries.removeAt(0);
    if (delivery == null) {
      completer.complete();
      return;
    }

    delivery.then(
      (_) => completer.complete(),
      onError: (Object error, StackTrace stackTrace) {
        completer.completeError(error, stackTrace);
      },
    );
  }

  Future<void> dispose() async {
    await _rCardsCtrl.close();
    await closeCredentialStreams();
  }
}

class _AwaitableBroadcastStream<T> extends Stream<T> {
  _AwaitableBroadcastStream(this._source, {required this.onDataHandled});

  final Stream<T> _source;
  final void Function(Future<void>? delivery) onDataHandled;

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _source.listen(
      (event) {
        final dynamic handler = onData;
        final result = handler?.call(event);
        onDataHandled(result is Future ? Future<void>.value(result) : null);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _TrackableStream<T> extends Stream<T> {
  _TrackableStream(
    this._source, {
    required this.onListen,
    required this.onCancel,
  });

  final Stream<T> _source;
  final void Function() onListen;
  final void Function() onCancel;

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    onListen();
    final subscription = _source.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    return _TrackedStreamSubscription<T>(subscription, onCancel);
  }
}

class _TrackedStreamSubscription<T> implements StreamSubscription<T> {
  _TrackedStreamSubscription(this._inner, this._onCancel);

  final StreamSubscription<T> _inner;
  final void Function() _onCancel;
  bool _isCanceled = false;

  @override
  Future<void> cancel() async {
    if (_isCanceled) return;
    _isCanceled = true;
    _onCancel();
    await _inner.cancel();
  }

  @override
  bool get isPaused => _inner.isPaused;

  @override
  void onData(void Function(T data)? handleData) => _inner.onData(handleData);

  @override
  void onDone(void Function()? handleDone) => _inner.onDone(handleDone);

  @override
  void onError(Function? handleError) => _inner.onError(handleError);

  @override
  void pause([Future<void>? resumeSignal]) => _inner.pause(resumeSignal);

  @override
  void resume() => _inner.resume();

  @override
  Future<E> asFuture<E>([E? futureValue]) => _inner.asFuture<E>(futureValue);
}

class FakeCredentialsSdk extends MeetingPlaceCredentialsSDK {
  FakeCredentialsSdk()
    : super(
        coreSDK: FakeMeetingPlaceSDK(),
        rCardRepository: FakeNoOpRCardRepository(),
        vrcRepository: FakeNoOpVrcRepository(),
      );

  final _controller = StreamController<RCard>.broadcast();
  final Completer<void> _channelListenerCompleter = Completer<void>();
  final List<Completer<void>> _pendingChannelDeliveries = [];
  late final StreamController<ChannelRCardEvent> _channelController =
      StreamController<ChannelRCardEvent>.broadcast(
        onListen: () {
          if (!_channelListenerCompleter.isCompleted) {
            _channelListenerCompleter.complete();
          }
        },
      );

  @override
  Stream<RCard> get receivedRCards => _controller.stream;

  @override
  Stream<ChannelRCardEvent> get receivedRCardsOnChannel =>
      _AwaitableBroadcastStream<ChannelRCardEvent>(
        _channelController.stream,
        onDataHandled: _completeNextPendingChannelDelivery,
      );

  void emit(RCard rCard) => _controller.add(rCard);
  void emitOnChannel(ChannelRCardEvent event) => _channelController.add(event);

  Future<void> waitForChannelRCardListener() =>
      _channelListenerCompleter.future;

  Future<void> emitOnChannelAndWait(ChannelRCardEvent event) {
    final completer = Completer<void>();
    _pendingChannelDeliveries.add(completer);
    _channelController.add(event);
    return completer.future;
  }

  void _completeNextPendingChannelDelivery(Future<void>? delivery) {
    if (_pendingChannelDeliveries.isEmpty) return;

    final completer = _pendingChannelDeliveries.removeAt(0);
    if (delivery == null) {
      completer.complete();
      return;
    }

    delivery.then(
      (_) => completer.complete(),
      onError: (Object error, StackTrace stackTrace) {
        completer.completeError(error, stackTrace);
      },
    );
  }

  Future<void> close() async {
    await _controller.close();
    await _channelController.close();
    await closeCredentialStreams();
  }
}
