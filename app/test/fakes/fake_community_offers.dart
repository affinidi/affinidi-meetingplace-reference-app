import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:ssi/ssi.dart';

/// A role card of a community, lasting until [validUntil].
Map<String, dynamic> fakeRoleCard(String validUntil) => {
  'type': ['VerifiableCredential', 'AuthorityCredential'],
  'issuer': 'did:webvh:community.example',
  'validUntil': validUntil,
};

/// A member's VTA that signs a statement with the admin card it holds.
class FakeAdminVtcService implements VtcService {
  Map<String, dynamic>? roleCard = fakeRoleCard('2026-12-01T10:00:00Z');
  final vouched = <String>[];

  @override
  Future<Map<String, dynamic>?> adminRoleCard(String communityDid) async =>
      roleCard;

  @override
  Future<Map<String, dynamic>> vouchForPhrase(
    String communityDid,
    String phrase,
  ) async {
    final card = roleCard;
    if (card == null) throw const NotCommunityAdminException();
    vouched.add(phrase);
    return {
      'type': CommunityOffer.statementType,
      'communityDid': communityDid,
      'phrase': phrase,
      'validUntil': card['validUntil'],
      'roleCard': card,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A join phrase statement for [phrase], signed as [admin] with the role
/// card [community] issued to them for [role], valid for a month.
Future<Map<String, dynamic>> signedJoinPhraseStatement({
  required String phrase,
  required Ed25519DidKeySigner community,
  required Ed25519DidKeySigner admin,
  String role = 'admin',
}) async {
  final now = DateTime.now().toUtc();
  final validUntil = formatTrustTaskTime(now.add(const Duration(days: 30)));
  final roleCard = await EddsaJcs2022.sign(
    {
      'type': ['VerifiableCredential', 'DTGCredential', 'AuthorityCredential'],
      'issuer': community.did,
      'validFrom': formatTrustTaskTime(now.subtract(const Duration(days: 1))),
      'validUntil': validUntil,
      'credentialSubject': {
        'id': admin.did,
        'authority': {
          'scope': community.did,
          'actions': ['role:$role'],
        },
      },
    },
    signer: community,
    purpose: ProofPurpose.assertionMethod,
  );
  return EddsaJcs2022.sign(
    {
      'type': CommunityOffer.statementType,
      'issuer': admin.did,
      'communityDid': community.did,
      'phrase': phrase,
      'validUntil': validUntil,
      'roleCard': roleCard,
    },
    signer: admin,
    purpose: ProofPurpose.assertionMethod,
  );
}

/// An offer someone else published under [mnemonic] with [contactInfo].
ConnectionOffer fakeFoundOffer(
  String mnemonic, {
  Map<String, dynamic> contactInfo = const {},
}) => ConnectionOffer(
  offerName: 'Not the community',
  offerLink: 'offer-$mnemonic',
  mnemonic: mnemonic,
  publishOfferDid: 'did:key:published',
  mediatorDid: 'did:web:mediator.example',
  oobInvitationMessage: '{}',
  type: ConnectionOfferType.meetingPlaceInvitation,
  status: ConnectionOfferStatus.published,
  contactCard: ContactCard(
    did: '',
    type: 'community',
    contactInfo: contactInfo,
  ),
  ownedByMe: false,
  createdAt: DateTime.utc(2026, 11, 5),
  transport: ChannelTransport.didcomm,
);

/// The Meeting Place SDK, keeping the offers this phone published.
class FakeOfferSdk implements MeetingPlaceCoreSDK {
  final offers = <ConnectionOffer>[];
  final requests = <PublishOfferRequest>[];
  final taken = <String>{};

  /// Offers others published, by phrase, to find.
  final found = <String, ConnectionOffer>{};

  /// The code finding an offer fails with, when set.
  MeetingPlaceCoreSDKErrorCode? findFailure;

  @override
  Future<FindOfferResult> findOffer({required String mnemonic}) async {
    final failure =
        findFailure ??
        (found.containsKey(mnemonic)
            ? null
            : MeetingPlaceCoreSDKErrorCode.connectionOfferNotFoundError);
    if (failure != null) {
      throw MeetingPlaceCoreSDKException(
        message: failure.value,
        code: failure.value,
        innerException: StateError(failure.value),
      );
    }
    return FindOfferResult(connectionOffer: found[mnemonic]);
  }

  @override
  Future<List<ConnectionOffer>> listConnectionOffers() async => List.of(offers);

  @override
  Future<ValidateOfferPhraseResult> validateOfferPhrase(String phrase) async =>
      ValidateOfferPhraseResult(isAvailable: !taken.contains(phrase));

  @override
  Future<PublishOfferResult<T>> publishOffer<T extends ConnectionOffer>(
    PublishOfferRequest request,
  ) async {
    requests.add(request);
    final offer = ConnectionOffer(
      offerName: request.offerName,
      offerLink: 'offer-${requests.length}',
      mnemonic: request.customMnemonic!,
      publishOfferDid: 'did:key:published',
      mediatorDid: 'did:web:mediator.example',
      oobInvitationMessage: '{}',
      type: ConnectionOfferType.meetingPlaceInvitation,
      status: ConnectionOfferStatus.published,
      contactCard: request.contactCard,
      ownedByMe: true,
      createdAt: DateTime.utc(2026, 11, 5),
      transport: ChannelTransport.didcomm,
      expiresAt: request.validUntil,
      externalRef: request.externalRef,
    );
    offers.add(offer);
    return _PublishResult(offer) as PublishOfferResult<T>;
  }

  @override
  Future<ConnectionOffer> markConnectionOfferAsDeleted(
    ConnectionOffer connectionOffer,
  ) async {
    final deleted = connectionOffer.markAsDeleted();
    offers[offers.indexOf(connectionOffer)] = deleted;
    return deleted;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _PublishResult implements PublishOfferResult<ConnectionOffer> {
  _PublishResult(this.connectionOffer);

  @override
  final ConnectionOffer connectionOffer;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
