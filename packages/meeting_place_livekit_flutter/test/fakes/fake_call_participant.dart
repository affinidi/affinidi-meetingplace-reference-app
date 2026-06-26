import 'package:matrix/matrix.dart' as matrix;
import 'package:meeting_place_livekit_flutter/src/delegates/matrix_encryption_key_provider_adapter.dart';

/// Test double for [matrix.CallParticipant] that provides a fixed [id]
/// without requiring a real [matrix.VoIP] instance.
///
/// We can't subclass [matrix.CallParticipant] without a real [matrix.VoIP]
/// because the constructor casts it at runtime. Instead we use a separate
/// class that conforms to the same interface as the production code expects.
///
/// [MatrixEncryptionKeyProviderAdapter] only reads [matrix.CallParticipant.id],
/// so this stub only needs to satisfy that read.
class FakeCallParticipant implements matrix.CallParticipant {
  FakeCallParticipant(this._id);

  final String _id;

  @override
  String get id => _id;

  @override
  String get userId => _id;

  @override
  String? get deviceId => null;

  @override
  matrix.VoIP get voip => throw UnimplementedError('not needed in tests');

  @override
  bool get isLocal => false;

  @override
  String toString() => _id;

  @override
  bool operator ==(Object other) =>
      other is FakeCallParticipant && other._id == _id;

  @override
  int get hashCode => _id.hashCode;
}
