import 'dart:convert';
import 'dart:typed_data';

import 'package:didcomm/didcomm.dart' hide TrustTaskDocument;
import 'package:dio/dio.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:ssi/ssi.dart';

/// A member's VTA over DIDComm, answering by task type, behind a mediator
/// that is an in-memory inbox.
///
/// Unpacks each forwarded request with its own key and authcrypts its
/// signed answer, addressed to the requester and threaded on the request,
/// back to the sender's inbox, as a VTA does. Grants every key admin and
/// `persona-holder` unless [answers] says otherwise for `whoami`.
///
/// Also an [HttpClientAdapter], so a fake network can hand it requests that
/// are not its own; it answers them with a 404.
class FakeVta implements HttpClientAdapter, DidResolver {
  FakeVta() {
    document = DidDocument.fromJson(
      DidKey.resolve(_key.did).toJson()
        ..['service'] = [
          {
            'id': '${_key.did}#vta-didcomm',
            'type': didCommMessagingServiceType,
            'serviceEndpoint': {
              'uri': _mediatorKey.did,
              'accept': ['didcomm/v2'],
            },
          },
        ],
    );
    answers[VtaTask.whoAmI] = {
      'roles': ['admin'],
      'capabilities': ['persona-holder'],
    };
  }

  /// When true, the VTA's mediator cannot be reached.
  bool isDown = false;

  final _key = Ed25519DidKeySigner.generate();
  final _mediatorKey = Ed25519DidKeySigner.generate();
  late final DidDocument document;
  final Map<String, Map<String, dynamic>> answers = {};

  /// Answers that depend on the request's payload, ahead of [answers].
  final Map<String, Map<String, dynamic> Function(Map<String, dynamic>)>
  answerTo = {};
  final Map<String, Map<String, dynamic>> refusals = {};
  final List<Map<String, dynamic>> received = [];
  final List<Map<String, dynamic>> _inbox = [];

  /// Other DID documents to resolve, such as a community's.
  final Map<String, DidDocument> otherDocuments = {};

  /// When set, `vault/sign-trust-task` signs as this persona.
  TrustTaskSigner? persona;

  String get did => _key.did;

  /// A [VtcService] linked to this VTA and granted, with what linking sent
  /// cleared from [received].
  Future<VtcService> linkedService() async {
    FlutterSecureStorage.setMockInitialValues({});
    final service = VtcService(
      sdk: sdk(),
      repository: SecureStorageVtcRepository(),
      userVerificationKey: UserVerificationKey(
        FakeUserVerificationKeyStorage(),
      ),
      platform: 'ios',
    );
    await service.startLink(did);
    await service.checkGrant();
    received.clear();
    return service;
  }

  /// An SDK that reaches only this VTA.
  MeetingPlaceVtcSDK sdk() => MeetingPlaceVtcSDK(
    didResolver: this,
    dio: Dio()..httpClientAdapter = this,
    openVtaMailbox: openMailbox,
  );

  /// Opens a manager key's inbox on this VTA's mediator.
  Future<VtaMailbox> openMailbox({
    required String mediatorDid,
    required DidDocument mediatorDocument,
    required DidManager manager,
  }) async {
    if (isDown) throw StateError('mediator down');
    return _FakeMailbox(this);
  }

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
  ) async => ResponseBody.fromString('{}', 404);

  Future<void> _receive(ForwardMessage forward) async {
    // A mediator answers on a later turn of the event loop, as I/O does.
    await Future<void>.delayed(Duration.zero);
    if (isDown) throw StateError('mediator down');
    final data = forward.attachments!.single.data!.base64!;
    final sealed =
        jsonDecode(
              utf8.decode(
                base64Url.decode(
                  data.padRight(data.length + (4 - data.length % 4) % 4, '='),
                ),
              ),
            )
            as Map<String, dynamic>;
    final message = await DidcommMessage.unpackToPlainTextMessage(
      message: sealed,
      recipientDidManager: await _didManager(),
      expectedMessageWrappingTypes: const [
        MessageWrappingType.authcryptPlaintext,
      ],
    );
    final answer = PlainTextMessage(
      id: 'urn:uuid:answer-${received.length}',
      type: Uri.parse(trustTaskEnvelopeType),
      from: did,
      to: [message.from!],
      threadId: message.id,
      body: await _answer(message.body!),
    );
    final packed = await EncryptedMessage.packWithAuthentication(
      answer,
      keyPair: _key.keyPair,
      didKeyId: DidKey.resolve(did).keyAgreement.first.id,
      recipientDidDocuments: [DidKey.resolve(message.from!)],
    );
    _inbox.add(packed.toJson());
  }

  Future<Map<String, dynamic>> _answer(Map<String, dynamic> request) async {
    received.add(request);
    final type = request['type'] as String;
    if (refusals[type] case final refusal?) {
      return {
        'id': 'urn:uuid:answer',
        'type': 'https://trusttasks.org/spec/trust-task-error/0.1',
        'issuer': did,
        'payload': refusal,
      };
    }
    final payload = switch (type) {
      VtaTask.signTrustTask when persona != null => {
        'signedEnvelope': await _signAsPersona(request),
      },
      _ =>
        answerTo[type]?.call(request['payload'] as Map<String, dynamic>) ??
            answers[type] ??
            const <String, dynamic>{},
    };
    return (await TrustTaskDocument.create(
      type: '$type#response',
      issuer: did,
      recipient: request['issuer'] as String,
      threadId: request['id'] as String,
      payload: payload,
    ).sign(_key, purpose: ProofPurpose.authentication)).toJson();
  }

  DidManager? _manager;

  Future<DidManager> _didManager() async {
    if (_manager case final manager?) return manager;
    final keyStore = InMemoryKeyStore();
    await keyStore.set(
      'vta',
      StoredKey(
        keyType: KeyType.ed25519,
        privateKeyBytes: Uint8List.fromList(ed.newKeyFromSeed(_key.seed).bytes),
      ),
    );
    final manager = DidKeyManager(
      store: InMemoryDidStore(),
      wallet: PersistentWallet(keyStore),
    );
    await manager.addVerificationMethod('vta');
    return _manager = manager;
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

class _FakeMailbox implements VtaMailbox {
  _FakeMailbox(this._vta);

  final FakeVta _vta;

  @override
  Future<void> send(ForwardMessage message) => _vta._receive(message);

  @override
  Future<List<Map<String, dynamic>>> take() async {
    await Future<void>.delayed(Duration.zero);
    if (_vta.isDown) throw StateError('mediator down');
    final messages = [..._vta._inbox];
    _vta._inbox.clear();
    return messages;
  }
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
