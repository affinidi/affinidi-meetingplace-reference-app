import 'dart:async';
import 'dart:convert';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/vdip_manager.dart'
    show VdipManager;

import 'fake_meeting_place_sdk.dart';
import 'fake_r_card_repository.dart';
import 'fake_vrc_repository.dart';

class StubRelationshipSdk extends MeetingPlaceRelationshipSDK {
  StubRelationshipSdk({
    required super.coreSDK,
    required super.rCardRepository,
    required super.vrcRepository,
    required VrcIssuance pendingVrc,
  }) : _pendingVrc = pendingVrc;

  VrcIssuance? _pendingVrc;

  @override
  VrcIssuance? consumePendingVrc(String senderDid) {
    final vrc = _pendingVrc;
    _pendingVrc = null;
    return vrc;
  }
}

/// A controllable [MeetingPlaceRelationshipSDK] stub for [VdipManager] tests.
/// Supports broadcasting events via [emitRequest]/[emitVrc] and configuring
/// the processing results returned by [handleReceivedVrcRequest] and
/// [handleReceivedVrc].
class StubVdipRelationshipSdk extends MeetingPlaceRelationshipSDK {
  StubVdipRelationshipSdk({
    required super.coreSDK,
    required super.rCardRepository,
    required super.vrcRepository,
  });

  final _requestCtrl = StreamController<VrcRequest>.broadcast();
  final _vrcCtrl = StreamController<VrcIssuance>.broadcast();

  VrcRequest? pendingRequest;
  VrcIssuance? pendingVrc;

  VrcRequestProcessingResult nextRequestResult =
      const VrcRequestProcessingResultPromptRequired();
  VrcProcessingResult nextVrcResult = const VrcProcessingResultIgnored();

  @override
  Stream<VrcRequest> get receivedVrcRequests => _requestCtrl.stream;

  @override
  Stream<VrcIssuance> get receivedVrcs => _vrcCtrl.stream;

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
  Future<VrcRequestProcessingResult> handleReceivedVrcRequest({
    required String permanentChannelDid,
    required VrcRequest request,
    required bool hasVrcExchangeInitiated,
    required bool isConnectionInitiator,
    String? issuerDid,
    String? issuerName,
  }) async => nextRequestResult;

  @override
  Future<VrcProcessingResult> handleReceivedVrc({
    required String permanentChannelDid,
    required String vcBlob,
    required VrcExchangeState exchangeState,
    String? issuerDid,
    String? issuerName,
  }) async => nextVrcResult;

  void emitRequest(VrcRequest r) => _requestCtrl.add(r);
  void emitVrc(VrcIssuance v) => _vrcCtrl.add(v);

  Future<void> dispose() async {
    await _requestCtrl.close();
    await _vrcCtrl.close();
    await closeRelationshipStreams();
  }
}

/// A controllable [MeetingPlaceRelationshipSDK] stub for RCardManager tests.
/// Supports broadcasting events via [emitRCard] and configuring the [RCard]
/// returned by [sendRCard].
class StubRCardRelationshipSdk extends MeetingPlaceRelationshipSDK {
  StubRCardRelationshipSdk({
    required super.coreSDK,
    required super.rCardRepository,
    required super.vrcRepository,
  });

  final _rCardsCtrl = StreamController<RCard>.broadcast();

  @override
  Stream<RCard> get receivedRCards => _rCardsCtrl.stream;

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

  Future<void> dispose() async {
    await _rCardsCtrl.close();
    await closeRelationshipStreams();
  }
}

class FakeRelationshipSdk extends MeetingPlaceRelationshipSDK {
  FakeRelationshipSdk()
    : super(
        coreSDK: FakeMeetingPlaceSDK(),
        rCardRepository: FakeNoOpRCardRepository(),
        vrcRepository: FakeNoOpVrcRepository(),
      );

  final _controller = StreamController<RCard>.broadcast();
  final _channelController = StreamController<ChannelRCardEvent>.broadcast();

  @override
  Stream<RCard> get receivedRCards => _controller.stream;

  @override
  Stream<ChannelRCardEvent> get receivedRCardsOnChannel =>
      _channelController.stream;

  void emit(RCard rCard) => _controller.add(rCard);
  void emitOnChannel(ChannelRCardEvent event) => _channelController.add(event);

  Future<void> close() async {
    await _controller.close();
    await _channelController.close();
    await closeRelationshipStreams();
  }
}
