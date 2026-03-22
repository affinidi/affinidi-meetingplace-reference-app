import 'package:matrix/matrix.dart' show CallParticipant, VoIP;

/// Minimal [CallParticipant] implementation — does not construct a real [VoIP].
/// Only [id], [userId], and [deviceId] are used by tests.
class FakeCallParticipant implements CallParticipant {
  FakeCallParticipant({required this.userId, this.deviceId});

  @override
  final String userId;

  @override
  final String? deviceId;

  @override
  VoIP get voip => throw UnimplementedError();

  @override
  bool get isLocal => throw UnimplementedError();

  @override
  String get id {
    var pid = userId;
    if (deviceId != null) pid += ':$deviceId';
    return pid;
  }

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) =>
      other is FakeCallParticipant &&
      userId == other.userId &&
      deviceId == other.deviceId;

  @override
  int get hashCode => Object.hash(userId.hashCode, deviceId.hashCode);
}
