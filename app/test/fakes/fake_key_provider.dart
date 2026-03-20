import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';

/// Fake [KeyProvider] that records every call for assertion.
/// Implements the abstract interface so no flutter-webrtc platform channel
/// is involved.
class FakeKeyProvider implements KeyProvider {
  final List<({String participantId, int keyIndex, Uint8List key})>
  setRawKeyCalls = [];
  final List<({String participantId, int keyIndex})> ratchetKeyCalls = [];
  final List<({String participantId, int keyIndex})> exportKeyCalls = [];

  static final stubKey = Uint8List.fromList(List.filled(32, 0xAB));

  @override
  Future<void> setRawKey(
    Uint8List key, {
    String? participantId,
    int? keyIndex,
  }) async {
    setRawKeyCalls.add((
      participantId: participantId ?? '',
      keyIndex: keyIndex ?? 0,
      key: key,
    ));
  }

  @override
  Future<Uint8List> ratchetKey(String participantId, int? keyIndex) async {
    ratchetKeyCalls.add((
      participantId: participantId,
      keyIndex: keyIndex ?? 0,
    ));
    return stubKey;
  }

  @override
  Future<Uint8List> exportKey(String participantId, int? keyIndex) async {
    exportKeyCalls.add((participantId: participantId, keyIndex: keyIndex ?? 0));
    return stubKey;
  }

  @override
  rtc.KeyProvider get keyProvider => throw UnimplementedError();
  @override
  Future<void> setSharedKey(String key, {int? keyIndex}) async {}
  @override
  Future<Uint8List> ratchetSharedKey({int? keyIndex}) async => stubKey;
  @override
  Future<Uint8List> exportSharedKey({int? keyIndex}) async => stubKey;
  @override
  Future<void> setKey(
    String key, {
    String? participantId,
    int? keyIndex,
  }) async {}
  @override
  Future<void> setSifTrailer(Uint8List trailer) async {}
}
