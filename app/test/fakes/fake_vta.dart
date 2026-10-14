import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:ssi/ssi.dart';

/// A member's VTA over the REST binding, answering by task type.
class FakeVta implements HttpClientAdapter, DidResolver {
  FakeVta() {
    document = DidDocument.fromJson(
      DidKey.resolve(_key.did).toJson()
        ..['service'] = [
          {
            'id': '${_key.did}#vta-rest',
            'type': 'VTARest',
            'serviceEndpoint': 'https://vta.example/api',
          },
        ],
    );
  }

  final _key = Ed25519DidKeySigner.generate();
  late final DidDocument document;
  final Map<String, Map<String, dynamic>> answers = {};
  final Map<String, Map<String, dynamic>> refusals = {};
  final List<Map<String, dynamic>> received = [];

  /// Other DID documents to resolve, such as a community's.
  final Map<String, DidDocument> otherDocuments = {};

  /// When set, `vault/sign-trust-task` signs as this persona.
  Ed25519DidKeySigner? persona;

  String get did => _key.did;

  /// An SDK that reaches only this VTA.
  MeetingPlaceVtcSDK sdk() => MeetingPlaceVtcSDK(
    didResolver: this,
    dio: Dio()..httpClientAdapter = this,
  );

  @override
  Future<DidDocument> resolveDid(String did) async {
    if (did == this.did) return document;
    if (otherDocuments[did] case final other?) return other;
    if (did.startsWith('did:key:')) return DidKey.resolve(did);
    throw StateError('unknown DID');
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = <int>[];
    await for (final chunk in requestStream!) {
      bytes.addAll(chunk);
    }
    final request = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    received.add(request);
    final type = request['type'] as String;

    final payload = switch (type) {
      VtaTask.signTrustTask when persona != null => {
        'signedEnvelope': await _signAsPersona(request),
      },
      VtaTask.challenge => {'sessionId': 's', 'challenge': 'c'},
      VtaTask.authenticate => {
        'tokens': {'accessToken': 'token'},
      },
      _ => answers[type] ?? const <String, dynamic>{},
    };
    final refusal = refusals[type];
    final answer = {
      'id': 'urn:uuid:answer',
      'type': refusal == null
          ? 'answer'
          : 'https://trusttasks.org/spec/trust-task-error/0.1',
      'issuer': did,
      'payload': refusal ?? payload,
    };
    return ResponseBody.fromString(
      jsonEncode(answer),
      refusal == null ? 200 : 400,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  Future<Map<String, dynamic>> _signAsPersona(Map<String, dynamic> request) {
    final payload = request['payload'] as Map<String, dynamic>;
    final unsigned = payload['unsignedEnvelope'] as Map<String, dynamic>;
    return EddsaJcs2022.sign(
      unsigned,
      signer: persona!,
      purpose: unsigned['type'] == OobTask.grant
          ? ProofPurpose.assertionMethod
          : ProofPurpose.authentication,
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Approval-key storage in memory.
class FakeUserVerificationKeyStorage implements UserVerificationKeyStorage {
  String? seed;
  String? did;

  @override
  Future<String?> readSeed() async => seed;

  @override
  Future<void> writeSeed(String value) async => seed = value;

  @override
  Future<String?> readDid() async => did;

  @override
  Future<void> writeDid(String value) async => did = value;

  @override
  Future<void> delete() async {
    seed = null;
    did = null;
  }
}
