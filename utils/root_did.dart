/// Generates a BIP39 mnemonic and derives its root DID.
///
/// Usage:
///   dart run utils/root_did.dart
///
/// Output (tab-separated, suitable for piping):
///   mnemonic: <24 words>
///   sha256:   <hex>
///   root_did: <did:key:...>

import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:crypto/crypto.dart';
import 'package:ssi/ssi.dart';

// Mirrors the derivation path used by MeetingPlaceCoreSDK.
const _rootKeyId = "m/44'/60'/0'/0'/0'";

Future<void> main() async {
  final mnemonic = Mnemonic.generate(
    Language.english,
    length: MnemonicLength.words12,
  );
  final sentence = mnemonic.sentence;
  final seed = Uint8List.fromList(mnemonic.seed);

  final wallet = Bip32Wallet.fromSeed(seed);
  await wallet.generateKey(keyId: _rootKeyId);

  final didManager = DidKeyManager(store: InMemoryDidStore(), wallet: wallet);
  await didManager.addVerificationMethod(_rootKeyId);
  final didDoc = await didManager.getDidDocument();

  final hash = sha256.convert(utf8.encode(sentence)).toString();

  print('mnemonic: $sentence');
  print('sha256:   $hash');
  print('root_did: ${didDoc.id}');
}
