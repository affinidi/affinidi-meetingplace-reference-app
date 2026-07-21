import 'dart:convert';
import 'dart:developer' as dev;

import 'package:didcomm/didcomm.dart';
import 'package:ssi/ssi.dart';
import 'package:vta_dart_client/vta_dart_client.dart';

class PlaintextDidCommPacker implements VtaDidCommPacker {
  PlaintextDidCommPacker({required this.didManager});

  final DidManager didManager;

  @override
  Future<String> pack({
    required String messageJson,
    required VtaDidCommEndpoint endpoint,
  }) async {
    return messageJson;
  }

  @override
  Future<VtaDidCommUnpackResult> unpack({required String packedMessage}) async {
    final decoded = jsonDecode(packedMessage);
    if (decoded is! Map<String, dynamic>) {
      return VtaDidCommUnpackResult(
        messageJson: packedMessage,
        senderAuthenticated: false,
      );
    }

    // Encrypted JWE envelope — decrypt it.
    if (decoded.containsKey('protected') && decoded.containsKey('ciphertext')) {
      try {
        final plainText = await DidcommMessage.unpackToPlainTextMessage(
          message: decoded,
          recipientDidManager: didManager,
        );
        final from = plainText.from;
        final messageMap = <String, dynamic>{
          'id': plainText.id,
          'type': plainText.type.toString(),
          'from': ?from,
          if (plainText.to != null) 'to': plainText.to,
          'body': plainText.body,
        };
        final json = jsonEncode(messageMap);
        dev.log(
          'PACKER DECRYPTED from=$from, type=${plainText.type}',
          name: 'SIGNSVC',
        );
        return VtaDidCommUnpackResult(
          messageJson: json,
          senderAuthenticated: true,
          senderDid: from,
          messageId: plainText.id,
          messageType: plainText.type.toString(),
        );
      } catch (e) {
        dev.log('PACKER DECRYPT ERROR: $e', name: 'SIGNSVC');
        return VtaDidCommUnpackResult(
          messageJson: packedMessage,
          senderAuthenticated: false,
        );
      }
    }

    // Plaintext envelope — pass through.
    return VtaDidCommUnpackResult(
      messageJson: packedMessage,
      senderAuthenticated: true,
      senderDid: decoded['from']?.toString(),
      messageId: decoded['id']?.toString(),
      threadId: decoded['thid']?.toString(),
      messageType: decoded['type']?.toString(),
    );
  }
}
