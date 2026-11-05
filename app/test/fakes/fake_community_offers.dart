import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';

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

/// The Meeting Place SDK, keeping the offers this phone published.
class FakeOfferSdk implements MeetingPlaceCoreSDK {
  final offers = <ConnectionOffer>[];
  final requests = <PublishOfferRequest>[];
  final taken = <String>{};

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
