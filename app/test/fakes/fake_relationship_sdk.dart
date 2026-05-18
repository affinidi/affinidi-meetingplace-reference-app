import 'dart:async';

import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import 'fake_meeting_place_sdk.dart';
import 'fake_r_card_repository.dart';

class FakeRelationshipSdk extends MeetingPlaceRelationshipSDK {
  FakeRelationshipSdk()
    : super(
        coreSDK: FakeMeetingPlaceSDK(),
        rCardRepository: FakeNoOpRCardRepository(),
      );

  final _controller = StreamController<RCard>.broadcast();

  @override
  Stream<RCard> get receivedRCards => _controller.stream;

  void emit(RCard rCard) => _controller.add(rCard);

  Future<void> close() async {
    await _controller.close();
    await closeRelationshipStreams();
  }
}
