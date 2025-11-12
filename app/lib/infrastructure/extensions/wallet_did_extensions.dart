import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:ssi/ssi.dart';

import 'did_extensions.dart';

/// Extension methods on [Wallet] for DID (Decentralized Identifier) generation.
extension WalletDidExtensions on Wallet {
  /// Returns a DID generated from the given [derivationPath].
  Future<String> did(String derivationPath) async {
    final keyPair = await generateKey(keyId: derivationPath);
    return DidKey.getDid(keyPair.publicKey);
  }

  /// Returns a SHA-256 hash of the DID generated from the given
  ///  [derivationPath].
  Future<String> didSha256(String derivationPath) async {
    return sha256
        .convert(utf8.encode(await did(derivationPath)))
        .toString()
        .topAndTail();
  }
}
