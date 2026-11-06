import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:didcomm/didcomm.dart' hide TrustTaskDocument;
import 'package:dio/dio.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:ssi/ssi.dart';

import 'fake_persona.dart';
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
    vta.otherDocuments[vetterDid] = DidDocument.fromJson({
      ...DidKey.resolve(vetterDid).toJson(),
      'service': [
        {
          'id': '$vetterDid#didcomm',
          'type': 'DIDCommMessaging',
          'serviceEndpoint': {
            'uri': mediatorDid,
            'accept': ['didcomm/v2'],
          },
        },
      ],
    });
  }

  final vta = FakeVta();

  /// A member of the community holding its vetter role.
  final vetterKey = Ed25519DidKeySigner.generate();

  /// The vetter's DID.
  String get vetterDid => vetterKey.did;

  /// The vetters the community lists.
  List<Map<String, dynamic>> listedVetters = [];

  /// What identities sent other members through their mediators.
  final List<ForwardMessage> sentToMembers = [];
  final _vtcKey = Ed25519DidKeySigner.generate();
  final _mediatorKey = Ed25519DidKeySigner.generate();

  /// DID of the mediator identities' mail goes to.
  String get mediatorDid => _mediatorKey.did;

  /// Messages waiting in identities' inboxes on the mediator, by id.
  final Map<String, Map<String, dynamic>> inbox = {};

  /// Ids of the messages deleted from [inbox].
  final List<String> inboxDeleted = [];

  /// How many times an identity signed in to its inbox.
  int inboxOpens = 0;

  /// When true, the mediator cannot be reached.
  bool isMediatorDown = false;
  final browserKey = Ed25519DidKeySigner.generate();
  final decisionClosesAt = formatTrustTaskTime(
    DateTime.now().add(const Duration(minutes: 10)),
  );
  String matchNumber = '47';
  int cancels = 0;
  bool approved = false;

  /// What the community asks of applicants.
  Map<String, dynamic> joinManifest = {
    'communityDid': fakeVtcDid,
    'branding': {'displayName': 'Football club'},
    'criteria': [
      {'id': 'open', 'admission': 'automatic', 'requirementsDigest': 'zOpen'},
    ],
  };

  /// The verdict on a join request. [applicant] anywhere in it stands for
  /// the DID that applied.
  Map<String, dynamic> joinVerdict = {
    'effect': 'allow',
    'with': {
      'role': 'member',
      'vmc': {
        'id': 'urn:uuid:vmc',
        'type': ['VerifiableCredential', 'MembershipCredential'],
        'issuer': fakeVtcDid,
        'credentialSubject': {'id': applicant},
      },
      'roleVac': {
        'id': 'urn:uuid:vac',
        'type': ['VerifiableCredential', 'AuthorityCredential'],
        'issuer': fakeVtcDid,
      },
    },
  };

  /// Stands for the applicant's DID in [joinVerdict].
  static const applicant = '<applicant>';

  /// Where a join request stands.
  String joinStatus = 'pending';

  /// The reason a rejected request's status gives.
  String? joinRejectionReason;

  /// The join documents the community received.
  final List<Map<String, dynamic>> joinRequests = [];

  /// When set, the community refuses a join submit with this code.
  String? joinRefusal;

  /// When set, the community refuses a withdraw with this code.
  String? withdrawRefusal;

  /// What `GET <base>/community/public-profile` answers, or null for a 404.
  Map<String, dynamic>? publicProfile = {
    'communityDid': fakeVtcDid,
    'name': 'Football club',
    'description': 'Five-a-side on Sundays.',
    'publicUrl': 'https://club.example/',
    'contactEmail': 'hello@club.example',
    'personhood': {'realHuman': true, 'singleMembership': true},
  };

  /// When set, the community refuses a leave with this HTTP status and code.
  (int, String)? leaveRefusal;

  /// The role a renewal's role card grants.
  String renewedRole = 'member';

  /// When set, the community refuses a renewal with this HTTP status and
  /// code.
  (int, String)? renewRefusal;

  /// Where the community publishes its revocation list.
  static const statusListUrl = '$fakeVtcOrigin/v1/status-lists/revocation';

  /// The places in the revocation list the community revoked.
  final Set<int> revoked = {};

  /// When true, the revocation list cannot be fetched.
  bool isStatusListDown = false;

  /// How many times the revocation list was fetched.
  int statusListFetches = 0;

  /// A card's `credentialStatus` for place [index] of the revocation list.
  static Map<String, dynamic> statusEntry(int index) => {
    'id': '$statusListUrl#$index',
    'type': 'BitstringStatusListEntry',
    'statusPurpose': 'revocation',
    'statusListIndex': '$index',
    'statusListCredential': statusListUrl,
  };

  static const _statusListBytes = 16;

  /// The member documents the community received: membership
  /// confirmations, directory card updates, leaves and renewals.
  final List<Map<String, dynamic>> memberRequests = [];

  /// A renewal's answer: fresh cards for [memberDid], the role card
  /// granting [renewedRole].
  Map<String, dynamic> _renewal(String memberDid) => {
    'did': memberDid,
    'vmc': {
      'id': 'urn:uuid:vmc-renewed',
      'type': ['VerifiableCredential', 'MembershipCredential'],
      'issuer': fakeVtcDid,
      'credentialSubject': {'id': memberDid},
    },
    'roleVac': {
      'id': 'urn:uuid:vac-renewed',
      'type': ['VerifiableCredential', 'AuthorityCredential'],
      'issuer': fakeVtcDid,
      'credentialSubject': {
        'id': memberDid,
        'authority': {
          'scope': fakeVtcDid,
          'actions': ['role:$renewedRole'],
        },
      },
    },
    'personhood': false,
    'personhoodChanged': false,
  };

  /// An SDK that reaches only this network.
  MeetingPlaceVtcSDK sdk() => MeetingPlaceVtcSDK(
    didResolver: vta,
    dio: Dio()..httpClientAdapter = this,
    openVtaMailbox: vta.openMailbox,
    openMediatorInbox: _openInbox,
    openMediatorOutbox: _openOutbox,
  );

  /// Puts a [type] document the vetter signed in [persona]'s inbox, sealed
  /// to the identity from the vetter, as vetters send them.
  Future<TrustTaskDocument> vetterSends(
    FakePersona persona,
    String type,
    Map<String, dynamic> payload, {
    String? threadId,
  }) async {
    final document = await TrustTaskDocument.create(
      type: type,
      issuer: vetterDid,
      recipient: persona.did,
      threadId: threadId,
      payload: payload,
    ).sign(vetterKey, purpose: ProofPurpose.authentication);
    final sealed = await EncryptedMessage.packWithAuthentication(
      PlainTextMessage(
        id: document.id,
        type: Uri.parse(type),
        from: vetterDid,
        to: [persona.did],
        body: document.toJson(),
      ),
      keyPair: vetterKey.keyPair,
      didKeyId: DidKey.resolve(vetterDid).keyAgreement.first.id,
      recipientDidDocuments: [persona.document],
    );
    inbox['message-${inbox.length + 1}'] =
        jsonDecode(jsonEncode(sealed)) as Map<String, dynamic>;
    return document;
  }

  /// The vetter's acceptance of [request], showing the community granted
  /// them [role].
  Future<TrustTaskDocument> vetterAccepts(
    FakePersona persona,
    Map<String, dynamic> request, {
    String role = 'vetter',
  }) async {
    final roleCard = await EddsaJcs2022.sign(
      {
        'type': [
          'VerifiableCredential',
          'DTGCredential',
          'AuthorityCredential',
        ],
        'issuer': fakeVtcDid,
        'issuerScope': 'public',
        'validFrom': '2026-01-01T00:00:00Z',
        'validUntil': '2099-01-01T00:00:00Z',
        'credentialSubject': {
          'id': vetterDid,
          'authority': {
            'scope': fakeVtcDid,
            'actions': ['role:$role'],
          },
        },
      },
      signer: _VtcSigner(_vtcKey),
      purpose: ProofPurpose.assertionMethod,
    );
    return vetterSends(persona, VettingTask.requestResponse, {
      'requestId': 'vr-1',
      'eligibilityVp': await EddsaJcs2022.sign(
        {
          'type': ['VerifiablePresentation'],
          'holder': vetterDid,
          'nonce': request['id'],
          'domain': persona.did,
          'verifiableCredential': [roleCard],
        },
        signer: vetterKey,
        purpose: ProofPurpose.authentication,
      ),
    }, threadId: request['id'] as String);
  }

  /// The vetter opens a session for the request they accepted.
  Future<TrustTaskDocument> vetterOpensSession(
    FakePersona persona, {
    List<String> requiredClaims = const ['name.legal'],
  }) => vetterSends(persona, VettingTask.session, {
    'requestId': 'vr-1',
    'challenge': 'QlScnBiVZptGM8oLBRk4S37fjuDCr381MUrrnd0cmHg',
    'domain': fakeVtcDid,
    'method': 'inPerson',
    'requiredClaims': requiredClaims,
    'expiresAt': formatTrustTaskTime(
      DateTime.now().add(const Duration(minutes: 15)),
    ),
  });

  /// The vetter vouches in [session] for the card named by [cardDigest] and
  /// [identityCommitment].
  Future<TrustTaskDocument> vetterVouches(
    FakePersona persona, {
    required Map<String, dynamic> session,
    required String cardDigest,
    required String identityCommitment,
  }) async {
    final statement = await EddsaJcs2022.sign(
      {
        'type': [
          'VerifiableCredential',
          'DTGCredential',
          'StatementCredential',
        ],
        'id': 'urn:uuid:statement',
        'issuer': vetterDid,
        'validFrom': formatTrustTaskTime(DateTime.now()),
        'validUntil': '2099-01-01T00:00:00Z',
        'taskContext': session['id'],
        'taskDigestMultibase': vettingDigest(session),
        'credentialSubject': {
          'id': persona.did,
          'predicate': VettingStatement.predicate,
          'object': {
            'value': {
              'community': fakeVtcDid,
              'method': 'inPerson',
              'documentClasses': ['passport'],
              'claimsVerified': ['name.legal'],
              'livenessConfirmed': true,
              'identityCommitment': identityCommitment,
              'cardDigestMultibase': cardDigest,
              'declaredRelationship': 'none',
            },
          },
        },
      },
      signer: vetterKey,
      purpose: ProofPurpose.assertionMethod,
    );
    return vetterSends(persona, VettingTask.issue, {
      'credential_response': {'credential': statement},
    }, threadId: session['id'] as String);
  }

  /// Signs [document] as [sender] and puts it in the inbox of the identity
  /// it names, sealed from [sender] as Meeting Place sends it, e.g. an
  /// applicant's request to a vetter. The recipient's DID document must
  /// resolve through [vta].
  Future<TrustTaskDocument> memberSends(
    FakePersona sender,
    TrustTaskDocument document,
  ) async {
    final signed = await document.sign(
      sender,
      purpose: ProofPurpose.authentication,
    );
    final sentBefore = sentToMembers.length;
    await sdk().personaMessenger(await sender.keys()).send(signed);
    inbox['message-${inbox.length + 1}'] = _sealedIn(
      sentToMembers.removeAt(sentBefore),
    );
    return signed;
  }

  /// The documents identities sent [recipient], opened with its keys,
  /// oldest first.
  Future<List<TrustTaskDocument>> sentTo(FakePersona recipient) async {
    final keys = await recipient.keys();
    return [
      for (final forward in sentToMembers)
        if (forward.next == recipient.did)
          TrustTaskDocument.fromJson(
            Map<String, dynamic>.of(
              (await DidcommMessage.unpackToPlainTextMessage(
                    message: _sealedIn(forward),
                    recipientDidManager: keys,
                    expectedMessageWrappingTypes: const [
                      MessageWrappingType.authcryptPlaintext,
                    ],
                  )).body ??
                  const {},
            ),
          ),
    ];
  }

  static Map<String, dynamic> _sealedIn(ForwardMessage forward) =>
      jsonDecode(
            utf8.decode(
              base64Url.decode(
                base64Url.normalize(forward.attachments!.single.data!.base64!),
              ),
            ),
          )
          as Map<String, dynamic>;

  /// A role card in which the community makes [holderDid] a vetter, signed
  /// by the community, its status at place [statusIndex] of the revocation
  /// list.
  Future<Map<String, dynamic>> vetterRoleCard(
    String holderDid, {
    int statusIndex = 3,
    String validUntil = '2099-01-01T00:00:00Z',
  }) => EddsaJcs2022.sign(
    {
      'id': 'urn:uuid:vetter-card',
      'type': ['VerifiableCredential', 'DTGCredential', 'AuthorityCredential'],
      'issuer': fakeVtcDid,
      'issuerScope': 'public',
      'validFrom': '2026-01-01T00:00:00Z',
      'validUntil': validUntil,
      'credentialStatus': statusEntry(statusIndex),
      'credentialSubject': {
        'id': holderDid,
        'authority': {
          'scope': fakeVtcDid,
          'actions': ['role:vetter'],
        },
      },
    },
    signer: _VtcSigner(_vtcKey),
    purpose: ProofPurpose.assertionMethod,
  );

  /// Delivers [credential] to [persona]'s inbox as the community does: a
  /// signed `credential-exchange/issue` document, sealed to the identity.
  Future<void> deliver(
    FakePersona persona,
    Map<String, dynamic> credential,
  ) async {
    final issue = await TrustTaskDocument.create(
      type: credentialIssueTask,
      issuer: fakeVtcDid,
      recipient: persona.did,
      payload: {
        'credential_response': {'credential': credential},
      },
    ).sign(_VtcSigner(_vtcKey), purpose: ProofPurpose.authentication);
    final sealed = await EncryptedMessage.packAnonymously(
      PlainTextMessage(
        id: issue.id,
        type: Uri.parse(trustTaskEnvelopeType),
        to: [persona.did],
        body: issue.toJson(),
      ),
      keyType: KeyType.ed25519,
      recipientDidDocuments: [persona.document],
      encryptionAlgorithm: EncryptionAlgorithm.a256cbc,
    );
    inbox['message-${inbox.length + 1}'] =
        jsonDecode(jsonEncode(sealed)) as Map<String, dynamic>;
  }

  /// The revocation list as the community signs it: [revoked] set in a
  /// GZIP bitstring, bit 0 the first byte's most significant, in bare
  /// base64url as the VTC writes it.
  Future<Map<String, dynamic>> _statusList() {
    final bits = Uint8List(_statusListBytes);
    for (final index in revoked) {
      bits[index ~/ 8] |= 1 << (7 - index % 8);
    }
    final encoded = base64Url.encode(gzip.encode(bits)).replaceAll('=', '');
    return EddsaJcs2022.sign(
      {
        '@context': ['https://www.w3.org/ns/credentials/v2'],
        'id': statusListUrl,
        'type': ['VerifiableCredential', 'BitstringStatusListCredential'],
        'issuer': fakeVtcDid,
        'credentialSubject': {
          'id': '$statusListUrl#list',
          'type': 'BitstringStatusList',
          'statusPurpose': 'revocation',
          'encodedList': encoded,
        },
      },
      signer: _VtcSigner(_vtcKey),
      purpose: ProofPurpose.assertionMethod,
    );
  }

  Future<MediatorOutbox> _openOutbox({
    required String mediatorDid,
    required DidDocument mediatorDocument,
    required DidManager manager,
  }) async {
    if (isMediatorDown) throw StateError('mediator down');
    return _FakeOutbox(this);
  }

  Future<MediatorInbox> _openInbox({
    required String mediatorDid,
    required DidDocument mediatorDocument,
    required DidManager manager,
  }) async {
    if (isMediatorDown) throw StateError('mediator down');
    inboxOpens++;
    return _FakeInbox(this);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.host != 'community.example') {
      return vta.fetch(options, requestStream, cancelFuture);
    }
    if (options.method == 'GET' && options.uri.toString() == statusListUrl) {
      statusListFetches++;
      return ResponseBody.fromString(
        jsonEncode(
          isStatusListDown ? {'error': 'unavailable'} : await _statusList(),
        ),
        isStatusListDown ? 503 : 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.method == 'GET') {
      final profile = options.uri.path.endsWith('/community/public-profile')
          ? publicProfile
          : null;
      return ResponseBody.fromString(
        jsonEncode(profile ?? {'error': 'not found'}),
        profile == null ? 404 : 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    final bytes = <int>[];
    await for (final chunk in requestStream!) {
      bytes.addAll(chunk);
    }
    final request = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final memberRefusal = switch (request['type']) {
      MemberTask.selfRemove => leaveRefusal,
      MemberTask.renew => renewRefusal,
      _ => null,
    };
    if (memberRefusal != null) {
      memberRequests.add(request);
      final (status, code) = memberRefusal;
      return ResponseBody.fromString(
        jsonEncode({
          'id': 'urn:uuid:error',
          'type': 'https://trusttasks.org/spec/trust-task-error/0.1',
          'issuer': fakeVtcDid,
          'payload': {'code': code},
        }),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
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
      'decisionClosesAt': decisionClosesAt,
      'ext': {
        'org.openvtc.session': {'audience': 'admin'},
      },
    };

    final Map<String, dynamic> answer;
    var purpose = ProofPurpose.assertionMethod;
    if (type == MemberTask.vmc ||
        type == MemberTask.directoryCardUpdate ||
        type == MemberTask.selfRemove ||
        type == MemberTask.renew) {
      memberRequests.add(request);
      purpose = ProofPurpose.authentication;
      answer = switch (type) {
        MemberTask.vmc => {'memberDid': request['issuer'], 'status': 'stored'},
        MemberTask.selfRemove => {
          'did': request['issuer'],
          'disposition': 'tombstone',
          'removed': true,
        },
        MemberTask.renew => _renewal(request['issuer'] as String),
        _ => {'revision': 1},
      };
    } else if (type == VettingCommunityTask.vettersList) {
      purpose = ProofPurpose.authentication;
      answer = {'vetters': listedVetters};
    } else if (type.startsWith(
      'https://trusttasks.org/spec/vtc/join-requests/',
    )) {
      joinRequests.add(request);
      final refusal = switch (type) {
        JoinTask.submit => joinRefusal,
        JoinTask.withdraw => withdrawRefusal,
        _ => null,
      };
      if (refusal != null) {
        return {
          'id': 'urn:uuid:error',
          'type': 'https://trusttasks.org/spec/trust-task-error/0.1',
          'issuer': fakeVtcDid,
          'payload': {'code': refusal},
        };
      }
      purpose = ProofPurpose.authentication;
      answer = switch (type) {
        JoinTask.manifest => joinManifest,
        JoinTask.submit => {
          'requestId': 'request-1',
          'verdict': _withApplicant(joinVerdict, request['issuer'] as String),
        },
        JoinTask.withdraw => {
          'requestId': payload['requestId'],
          'status': joinStatus = 'withdrawn',
        },
        _ => {
          'requestId': payload['requestId'],
          'status': joinStatus,
          'reason': ?joinRejectionReason,
        },
      };
    } else if (type == OobTask.claim) {
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
    ).sign(signer, purpose: purpose);
    return signed.toJson();
  }

  @override
  void close({bool force = false}) {}

  static dynamic _withApplicant(Object? value, String did) => switch (value) {
    applicant => did,
    final Map<String, dynamic> map => {
      for (final MapEntry(:key, :value) in map.entries)
        key: _withApplicant(value, did),
    },
    final List<dynamic> list => [
      for (final item in list) _withApplicant(item, did),
    ],
    _ => value,
  };
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

class _FakeInbox implements MediatorInbox {
  _FakeInbox(this._network);

  final FakeVtcNetwork _network;

  @override
  Future<List<String>> listIds() async => _network.inbox.keys.toList();

  @override
  Future<Map<String, dynamic>?> fetch(String id) async => _network.inbox[id];

  @override
  Future<void> delete(List<String> ids) async {
    _network.inboxDeleted.addAll(ids);
    ids.forEach(_network.inbox.remove);
  }

  @override
  Future<void> close() async {}
}

class _FakeOutbox implements MediatorOutbox {
  _FakeOutbox(this._network);

  final FakeVtcNetwork _network;

  @override
  Future<void> send(ForwardMessage message) async =>
      _network.sentToMembers.add(message);

  @override
  Future<void> close() async {}
}
