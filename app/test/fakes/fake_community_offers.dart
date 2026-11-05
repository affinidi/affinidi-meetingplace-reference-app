import 'package:meeting_place_core/meeting_place_core.dart';

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
