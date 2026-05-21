import 'dart:async';

import 'package:meeting_place_core/meeting_place_core.dart' show Channel;
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import 'fake_meeting_place_sdk.dart';
import 'fake_r_card_repository.dart';
import 'fake_vrc_repository.dart';

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

  void emitOnChannel(Channel channel, RCard rCard) =>
      _channelController.add(ChannelRCardEvent(channel: channel, rCard: rCard));

  Future<void> close() async {
    await _controller.close();
    await _channelController.close();
    await closeRelationshipStreams();
  }
}
