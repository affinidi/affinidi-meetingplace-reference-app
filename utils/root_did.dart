// Generates a BIP39 mnemonic and derives its root DID.
//
// Usage:
//   dart run utils/root_did.dart
//
// Output:
//   mnemonic: <24 words>
//   sha256:   <hex>
//   root_did: <did:key:...>
//   wrote mnemonic_qr.png

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ascii_qr/ascii_qr.dart';
import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';
import 'package:ssi/ssi.dart';

// Mirrors the derivation path used by MeetingPlaceCoreSDK.
const _rootKeyId = "m/44'/60'/0'/0'/0'";

const _outPath = 'mnemonic_qr.png';

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

  stdout.writeln('mnemonic: $sentence');
  stdout.writeln('sha256:   $hash');
  stdout.writeln('root_did: ${didDoc.id}');
  stdout.writeln('');
  stdout.writeln(AsciiQrGenerator.generate(sentence, horizontalScale: 2));
  stdout.writeln('');
  stdout.writeln('For development environment, set WALLET_CONFIG to:');
  stdout.writeln(
    jsonEncode({
      hash: {"ciergeConnectorDid": '<agent-connector-did>'},
    }),
  );

  await _writePng(sentence);
  stdout.writeln('wrote $_outPath');
}

Future<void> _writePng(String data) async {
  const qrSizePx = 600;
  const quietZone = 24;

  final qrCode = QrCode.fromData(
    data: data,
    errorCorrectLevel: QrErrorCorrectLevel.L,
  );
  final qrImage = QrImage(qrCode);
  final modules = qrImage.moduleCount;

  final moduleSize = (qrSizePx - 2 * quietZone) ~/ modules;
  final total = moduleSize * modules + 2 * quietZone;

  final image = img.Image(width: total, height: total);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));

  for (var row = 0; row < modules; row++) {
    for (var col = 0; col < modules; col++) {
      if (qrImage.isDark(row, col)) {
        final x = quietZone + col * moduleSize;
        final y = quietZone + row * moduleSize;
        img.fillRect(
          image,
          x1: x,
          y1: y,
          x2: x + moduleSize - 1,
          y2: y + moduleSize - 1,
          color: img.ColorRgb8(0, 0, 0),
        );
      }
    }
  }

  await File(_outPath).writeAsBytes(img.encodePng(image));
}
