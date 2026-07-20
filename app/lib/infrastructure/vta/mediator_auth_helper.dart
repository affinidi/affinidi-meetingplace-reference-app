import 'package:didcomm/didcomm.dart';
import 'package:dio/dio.dart';
import 'package:ssi/ssi.dart';
import 'package:uuid/uuid.dart';

class MediatorAuthHelper {
  MediatorAuthHelper._();

  static Future<String> authenticate({
    required DidDocument mediatorDidDocument,
    required DidManager didManager,
  }) async {
    final ownDidDocument = await didManager.getDidDocument();

    final matchedKeyIds = ownDidDocument.matchKeysInKeyAgreement(
      otherDidDocuments: [mediatorDidDocument],
    );
    if (matchedKeyIds.isEmpty) {
      throw StateError(
        'No suitable key found for key agreement with the mediator.',
      );
    }

    final didKeyId = matchedKeyIds.first;
    final keyPair = await didManager.getKeyPairByDidKeyId(didKeyId);
    final signer =
        await didManager.getSigner(didManager.authentication.first);
    final did = getDidFromId(didKeyId);

    final authUrl = _findAuthEndpoint(mediatorDidDocument);
    if (authUrl == null) {
      throw StateError(
        'No Authentication service endpoint in mediator DID document',
      );
    }

    final dio = Dio(BaseOptions(
      baseUrl: authUrl,
      contentType: 'application/json',
    ));

    final challengeResponse = await dio.post<Map<String, dynamic>>(
      '/challenge',
      data: {'did': did},
    );

    final createdTime = DateTime.now().toUtc();
    final expiresTime = createdTime.add(const Duration(seconds: 60));

    final plainTextMessage = PlainTextMessage(
      id: const Uuid().v4(),
      type: Uri.parse('https://affinidi.com/atm/1.0/authenticate'),
      createdTime: createdTime,
      expiresTime: expiresTime,
      from: did,
      to: [mediatorDidDocument.id],
      body: challengeResponse.data!['data'] as Map<String, dynamic>,
    );

    final encryptedMessage =
        await DidcommMessage.packIntoSignedAndEncryptedMessages(
      plainTextMessage,
      keyPair: keyPair,
      didKeyId: didKeyId,
      recipientDidDocuments: [mediatorDidDocument],
      encryptionAlgorithm: EncryptionAlgorithm.a256cbc,
      keyWrappingAlgorithm: KeyWrappingAlgorithm.ecdh1Pu,
      signer: signer,
    );

    final authenticateResponse = await dio.post<Map<String, dynamic>>(
      '',
      data: encryptedMessage,
    );

    final data = authenticateResponse.data!['data'] as Map<String, dynamic>;
    return data['access_token'] as String;
  }

  static String? _findAuthEndpoint(DidDocument doc) {
    for (final service in doc.service) {
      if (_serviceTypeMatches(service.type, 'Authentication')) {
        return _extractUrl(service.serviceEndpoint);
      }
    }
    return null;
  }

  static bool _serviceTypeMatches(ServiceType serviceType, String value) {
    if (serviceType is StringServiceType) return serviceType.value == value;
    if (serviceType is SetServiceType) {
      return serviceType.values.contains(value);
    }
    return false;
  }

  static String? _extractUrl(ServiceEndpointValue value) {
    switch (value) {
      case StringEndpoint(:final url):
        return url;
      case MapEndpoint(:final data):
        return data['uri'] as String?;
      case SetEndpoint(:final endpoints):
        if (endpoints.isNotEmpty) return _extractUrl(endpoints.first);
    }
    return null;
  }
}
