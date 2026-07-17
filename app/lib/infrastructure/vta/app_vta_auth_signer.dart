import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:vta_dart_client/vta_dart_client.dart';

import '../secure_storage/secure_storage.dart';

class AppVtaAuthSigner implements VtaAuthSigner {
  AppVtaAuthSigner({
    required SecureStorage secureStorage,
    required this.holderDid,
    required this.verificationMethod,
  }) : _secureStorage = secureStorage;

  final SecureStorage _secureStorage;
  final String holderDid;
  final String verificationMethod;

  static final _ed25519 = Ed25519();
  static final _sha256 = Sha256();

  @override
  Future<Map<String, dynamic>> createProof({
    required Map<String, dynamic> trustTask,
    required String operation,
  }) async {
    final keyPair = await _secureStorage.getKeyPair(holderDid);
    if (keyPair == null) {
      throw StateError('No key pair found for DID: $holderDid');
    }

    final proofConfig = <String, dynamic>{
      'type': 'DataIntegrityProof',
      'cryptosuite': 'eddsa-jcs-2022',
      'created': DateTime.now().toUtc().toIso8601String(),
      'verificationMethod': verificationMethod,
      'proofPurpose': 'authentication',
    };

    final canonicalDoc = _canonicalizeJson(trustTask);
    final canonicalProof = _canonicalizeJson(proofConfig);

    final proofDigest =
        (await _sha256.hash(utf8.encode(canonicalProof))).bytes;
    final docDigest =
        (await _sha256.hash(utf8.encode(canonicalDoc))).bytes;
    final signingInput = <int>[...proofDigest, ...docDigest];

    final edKeyPair = await _ed25519.newKeyPairFromSeed(
      keyPair.privateKeyBytes,
    );
    final signature = await _ed25519.sign(signingInput, keyPair: edKeyPair);
    final proofValue = 'z${_base58Encode(signature.bytes)}';

    return <String, dynamic>{...proofConfig, 'proofValue': proofValue};
  }

  static String _canonicalizeJson(dynamic value) {
    if (value == null || value is bool || value is num || value is String) {
      return jsonEncode(value);
    }
    if (value is List) {
      return '[${value.map(_canonicalizeJson).join(',')}]';
    }
    if (value is Map) {
      final entries = value.entries
          .map((e) => MapEntry(e.key.toString(), e.value))
          .toList(growable: false)
        ..sort((a, b) => a.key.compareTo(b.key));
      final buffer = StringBuffer('{');
      for (var i = 0; i < entries.length; i++) {
        if (i > 0) buffer.write(',');
        buffer.write(jsonEncode(entries[i].key));
        buffer.write(':');
        buffer.write(_canonicalizeJson(entries[i].value));
      }
      buffer.write('}');
      return buffer.toString();
    }
    throw FormatException('Unsupported JSON type: ${value.runtimeType}');
  }

  static const _alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  static String _base58Encode(List<int> bytes) {
    if (bytes.isEmpty) return '';
    final digits = <int>[];
    for (final byte in bytes) {
      var carry = byte;
      for (var i = 0; i < digits.length; i++) {
        carry += digits[i] << 8;
        digits[i] = carry % 58;
        carry ~/= 58;
      }
      while (carry > 0) {
        digits.add(carry % 58);
        carry ~/= 58;
      }
    }
    final output = StringBuffer();
    for (final byte in bytes) {
      if (byte == 0) {
        output.write(_alphabet[0]);
      } else {
        break;
      }
    }
    for (final digit in digits.reversed) {
      output.write(_alphabet[digit]);
    }
    return output.toString();
  }
}
