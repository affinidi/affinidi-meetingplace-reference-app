import 'package:meeting_place_matrix/meeting_place_matrix.dart';

/// Fake [AudioVideoCallParticipant] for testing.
class FakeAudioVideoCallParticipant implements AudioVideoCallParticipant {
  @override
  bool get isSelf => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
