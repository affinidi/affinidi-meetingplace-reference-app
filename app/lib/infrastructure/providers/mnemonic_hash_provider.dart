import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../secure_storage/secure_storage.dart';

typedef MnemonicHashData = ({String mnemonic, String hash});

String _computeMnemonicHash(String mnemonic) {
  return sha256.convert(utf8.encode(mnemonic)).toString();
}

final mnemonicHashProvider = FutureProvider.autoDispose<MnemonicHashData?>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final mnemonic = await secureStorage.getMnemonic();
  if (mnemonic == null || mnemonic.isEmpty) {
    return null;
  }
  return (mnemonic: mnemonic, hash: _computeMnemonicHash(mnemonic));
}, name: 'mnemonicHashProvider');
