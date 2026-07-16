import 'dart:typed_data';

import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:webrtc_interface/webrtc_interface.dart' as rtc;

/// Test double for [lk.KeyProvider] that records calls without touching
/// native WebRTC plugins.
class FakeKeyProvider implements lk.KeyProvider {
  final List<({String participantId, Uint8List key, int index})>
  setRawKeyCalls = [];
  final List<({String participantId, int index})> ratchetKeyCalls = [];
  final List<({String participantId, int index})> exportKeyCalls = [];

  Uint8List returnedRatchetKey = Uint8List.fromList([1, 2, 3]);
  Uint8List returnedExportKey = Uint8List.fromList([4, 5, 6]);

  @override
  Future<void> setRawKey(
    Uint8List key, {
    String? participantId,
    int? keyIndex,
  }) async {
    setRawKeyCalls.add((
      participantId: participantId ?? '',
      key: key,
      index: keyIndex ?? 0,
    ));
  }

  @override
  Future<Uint8List> ratchetKey(String participantId, int? keyIndex) async {
    ratchetKeyCalls.add((participantId: participantId, index: keyIndex ?? 0));
    return returnedRatchetKey;
  }

  @override
  Future<Uint8List> exportKey(String participantId, int? keyIndex) async {
    exportKeyCalls.add((participantId: participantId, index: keyIndex ?? 0));
    return returnedExportKey;
  }

  @override
  Future<void> setSharedKey(String key, {int? keyIndex}) async {}

  @override
  Future<Uint8List> ratchetSharedKey({int? keyIndex}) async =>
      Uint8List.fromList([7, 8, 9]);

  @override
  Future<Uint8List> exportSharedKey({int? keyIndex}) async => Uint8List(0);

  @override
  Future<void> setKey(
    String key, {
    String? participantId,
    int? keyIndex,
  }) async {}

  @override
  Future<void> setSifTrailer(Uint8List trailer) async {}

  @override
  rtc.KeyProvider get keyProvider => _FakeRtcKeyProvider();
}

class _FakeRtcKeyProvider implements rtc.KeyProvider {
  @override
  String get id => 'fake-key-provider';

  @override
  Future<bool> setKey({
    required String participantId,
    required int index,
    required Uint8List key,
  }) async => true;

  @override
  Future<bool> setSharedKey({required Uint8List key, int index = 0}) async =>
      true;

  @override
  Future<Uint8List> ratchetKey({
    required String participantId,
    required int index,
  }) async => Uint8List.fromList([1, 2, 3]);

  @override
  Future<Uint8List> exportKey({
    required String participantId,
    required int index,
  }) async => Uint8List(0);

  @override
  Future<Uint8List> ratchetSharedKey({int index = 0}) async =>
      Uint8List.fromList([4, 5, 6]);

  @override
  Future<Uint8List> exportSharedKey({int index = 0}) async => Uint8List(0);

  @override
  Future<void> setSifTrailer({required Uint8List trailer}) async {}

  @override
  Future<void> dispose() async {}
}
