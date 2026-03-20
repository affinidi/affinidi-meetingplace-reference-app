import 'dart:typed_data';

import 'package:livekit_client/livekit_client.dart';
import 'package:matrix/matrix.dart' show CallParticipant, EncryptionKeyProvider;

import '../../loggers/app_logger/app_logger.dart';

/// Provides per-participant LiveKit FrameCryptor E2EE for audio/video frames.
///
/// When `e2eeEnabled: true` is set on the `LiveKitBackend`, the Matrix SDK
/// distributes unique per-participant keys via Olm-encrypted to-device
/// messages. The three [EncryptionKeyProvider] callbacks bridge the Matrix SDK
/// key distribution into the LiveKit FrameCryptor:
/// - `onSetEncryptionKey` — forward a received remote participant key
/// into LiveKit.
/// - `onRatchetKey` — rotate the local participant's key and return
/// the new value.
/// - `onExportKey` — export the current local key for distribution to
/// late joiners.
class MatrixLiveKitKeyProvider implements EncryptionKeyProvider {
  MatrixLiveKitKeyProvider._(this._liveKitKeyProvider, this._logger);

  final BaseKeyProvider _liveKitKeyProvider;
  final AppLogger _logger;

  static const _logKey = 'MTRXLVKKEYPROV';

  BaseKeyProvider get liveKitKeyProvider => _liveKitKeyProvider;

  static Future<MatrixLiveKitKeyProvider> create({
    required AppLogger logger,
  }) async {
    final provider = await BaseKeyProvider.create(sharedKey: false);
    return MatrixLiveKitKeyProvider._(provider, logger);
  }

  static Future<MatrixLiveKitKeyProvider> fromKey({
    required String e2eeKey,
    required AppLogger logger,
  }) async {
    final provider = await BaseKeyProvider.create(sharedKey: true);
    await provider.setSharedKey(e2eeKey);
    return MatrixLiveKitKeyProvider._(provider, logger);
  }

  @override
  Future<void> onSetEncryptionKey(
    CallParticipant participant,
    Uint8List key,
    int index,
  ) async {
    _logger.info(
      'Stored remote key in FrameCryptor — '
      'participant=${participant.userId} idx=$index',
      name: _logKey,
    );
    await _liveKitKeyProvider.setRawKey(
      key,
      participantId: participant.id,
      keyIndex: index,
    );
  }

  @override
  Future<Uint8List> onRatchetKey(CallParticipant participant, int index) {
    _logger.info(
      'Rotating local encryption key — '
      'participant=${participant.userId} idx=$index',
      name: _logKey,
    );
    return _liveKitKeyProvider.ratchetKey(participant.id, index);
  }

  @override
  Future<Uint8List> onExportKey(CallParticipant participant, int index) {
    _logger.info(
      'Exporting local key for late joiner — '
      'participant=${participant.userId} idx=$index',
      name: _logKey,
    );
    return _liveKitKeyProvider.exportKey(participant.id, index);
  }
}
