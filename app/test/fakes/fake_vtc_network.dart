import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:ssi/ssi.dart';

import 'fake_vta.dart';

const fakeVtcDid = 'did:web:community.example';
const fakeVtcOrigin = 'https://community.example';

/// A community and a member's VTA, each answering its own host.
class FakeVtcNetwork implements HttpClientAdapter {
  FakeVtcNetwork() {
    vta.otherDocuments[fakeVtcDid] = DidDocument.fromJson({
      '@context': ['https://www.w3.org/ns/did/v1'],
      'id': fakeVtcDid,
      'verificationMethod': [
        {
          'id': '$fakeVtcDid#key-0',
          'type': 'Multikey',
          'controller': fakeVtcDid,
          'publicKeyMultibase': _vtcKey.did.substring('did:key:'.length),
        },
      ],
      'authentication': ['$fakeVtcDid#key-0'],
      'assertionMethod': ['$fakeVtcDid#key-0'],
      'service': [
        {
          'id': '$fakeVtcDid#trust-tasks',
          'type': 'TrustTaskHTTPS',
          'serviceEndpoint': '$fakeVtcOrigin/v1',
        },
        {
          'id': '$fakeVtcDid#sign-in-portal',
          'type': 'SignInPortal',
          'serviceEndpoint': '$fakeVtcOrigin/admin/',
        },
      ],
    });
  }

  final vta = FakeVta();
  final _vtcKey = Ed25519DidKeySigner.generate();
  final browserKey = Ed25519DidKeySigner.generate();
  final decisionDeadline = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 600;
  String matchNumber = '47';
  int cancels = 0;
  bool approved = false;

  /// An SDK that reaches only this network.
  MeetingPlaceVtcSDK sdk() => MeetingPlaceVtcSDK(
    didResolver: vta,
    dio: Dio()..httpClientAdapter = this,
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.host != 'community.example') {
      return vta.fetch(options, requestStream, cancelFuture);
    }
    final bytes = <int>[];
    await for (final chunk in requestStream!) {
      bytes.addAll(chunk);
    }
    final request = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ResponseBody.fromString(
      jsonEncode(await _answer(request)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  Future<Map<String, dynamic>> _answer(Map<String, dynamic> request) async {
    final type = request['type'] as String;
    final payload = request['payload'] as Map<String, dynamic>;
    final step1 = {
      'requestId': request['parentThreadId'],
      'service': {'did': fakeVtcDid},
      'purpose': 'login',
      'origin': fakeVtcOrigin,
      'decisionDeadline': decisionDeadline,
      'ext': {
        'org.openvtc.session': {'audience': 'admin'},
      },
    };

    final Map<String, dynamic> answer;
    if (type == OobTask.claim) {
      answer = step1;
    } else if (type == OobTask.prove) {
      final identify = payload['identify'] as Map<String, dynamic>;
      final number = (identify['payload'] as Map)['enteredNumber'];
      if (number != matchNumber) {
        return {
          'id': 'urn:uuid:error',
          'type': 'https://trusttasks.org/spec/trust-task-error/0.1',
          'issuer': fakeVtcDid,
          'payload': {'code': 'auth/oob/prove:numberMismatch'},
        };
      }
      answer = {
        ...step1,
        'sessionKey': browserKey.did,
        'identifiedAs': identify['issuer'],
        'requester': {
          'browser': 'Firefox',
          'os': 'Linux',
          'location': 'Berlin, DE',
          'sameNetwork': false,
          'createdAt': '2026-10-14T12:00:00Z',
        },
      };
    } else if (type == OobTask.respond) {
      approved = true;
      answer = {'status': 'approved'};
    } else {
      cancels++;
      answer = {'status': 'cancelled'};
    }

    final signer = _VtcSigner(_vtcKey);
    final signed = await TrustTaskDocument.create(
      type: '$type#response',
      issuer: fakeVtcDid,
      recipient: request['issuer'] as String,
      threadId: request['id'] as String,
      payload: answer,
    ).sign(signer, purpose: ProofPurpose.assertionMethod);
    return signed.toJson();
  }

  @override
  void close({bool force = false}) {}
}

class _VtcSigner implements TrustTaskSigner {
  _VtcSigner(this._key);

  final Ed25519DidKeySigner _key;

  @override
  String get did => fakeVtcDid;

  @override
  String get verificationMethod => '$fakeVtcDid#key-0';

  @override
  Future<Uint8List> sign(Uint8List data) => _key.sign(data);
}
