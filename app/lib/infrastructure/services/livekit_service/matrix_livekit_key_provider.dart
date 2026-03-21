import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:livekit_client/livekit_client.dart';
import 'package:matrix/matrix.dart' show CallParticipant, EncryptionKeyProvider;

/// Provides end-to-end encryption for LiveKit media streams.
///
/// Uses a shared-key scheme: all participants in the same room derive an
/// identical 32-byte key from `HMAC-SHA256(apiSecret, roomId)`. The LiveKit
/// SFU forwards encrypted frames without being able to decrypt them.
///
/// The `EncryptionKeyProvider` callbacks (`onSetEncryptionKey`,
/// `onRatchetKey`, `onExportKey`) are intentionally no-ops / shared-key
/// delegates. The Matrix SDK's `LiveKitBackend.e2eeEnabled` defaults to
/// `true`, but because the delegate's `keyProvider` is left `null`, the
/// SDK's per-participant key distribution is silently disabled. All
/// encryption is handled by LiveKit's shared-key FrameCryptor.
class MatrixLiveKitKeyProvider implements EncryptionKeyProvider {
  MatrixLiveKitKeyProvider._(this._liveKitKeyProvider);

  final KeyProvider _liveKitKeyProvider;

  /// The underlying `BaseKeyProvider` to pass to `LiveKitService.connect`
  /// via `e2eeKeyProvider`.
  BaseKeyProvider get liveKitKeyProvider =>
      _liveKitKeyProvider as BaseKeyProvider;

  /// Creates a `MatrixLiveKitKeyProvider` with a shared key derived from
  /// `HMAC-SHA256(apiSecret, roomId)`.
  ///
  /// Both participants independently compute the same key — no key exchange
  /// over the network is required for this to work.
  ///
  /// Dev-only: `apiSecret` is used in-app to derive the key. Once a token
  /// server is in place, use `fromKey` instead and pass the pre-derived key
  /// returned by the server.
  static Future<MatrixLiveKitKeyProvider> create({
    required String roomId,
    required String apiSecret,
  }) async {
    return fromKey(
      e2eeKey: deriveSharedKey(apiSecret: apiSecret, roomId: roomId),
    );
  }

  /// Creates a `MatrixLiveKitKeyProvider` from a pre-derived key.
  ///
  /// Use this once a token server is available and the server returns the
  /// E2EE key alongside the LiveKit JWT. The `e2eeKey` must be a 64-char
  /// lowercase hex string (32 bytes) — the same format produced by
  /// `deriveSharedKey`.
  static Future<MatrixLiveKitKeyProvider> fromKey({
    required String e2eeKey,
  }) async {
    final provider = await BaseKeyProvider.create(sharedKey: true);
    await provider.setSharedKey(e2eeKey);
    return MatrixLiveKitKeyProvider._(provider);
  }

  /// Constructs from an existing provider — test-only, avoids platform channel.
  @visibleForTesting
  static MatrixLiveKitKeyProvider forTest(KeyProvider provider) =>
      MatrixLiveKitKeyProvider._(provider);

  /// Derives the 64-char hex shared-key from `apiSecret` and `roomId`.
  ///
  /// Exposed as a static method so it can be unit-tested without requiring
  /// the LiveKit native platform channel.
  static String deriveSharedKey({
    required String apiSecret,
    required String roomId,
  }) {
    final keyBytes = Hmac(
      sha256,
      utf8.encode(apiSecret),
    ).convert(utf8.encode(roomId)).bytes;
    return keyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // ── EncryptionKeyProvider interface ──────────────────────────────────────
  // These callbacks are invoked by the Matrix SDK when per-participant key
  // distribution is active (LiveKitBackend.e2eeEnabled = true). With the
  // shared-key approach the delegate's keyProvider is left null, so these
  // are never actually called. They are here for interface compliance and
  // for future upgrade to full Matrix-coordinated E2EE.

  @override
  Future<void> onSetEncryptionKey(
    CallParticipant participant,
    Uint8List key,
    int index,
  ) async {}

  @override
  Future<Uint8List> onRatchetKey(CallParticipant participant, int index) =>
      _liveKitKeyProvider.ratchetSharedKey(keyIndex: index);

  @override
  Future<Uint8List> onExportKey(CallParticipant participant, int index) =>
      _liveKitKeyProvider.exportSharedKey(keyIndex: index);
}
