import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';

/// Thrown when a join phrase is already registered in Meeting Place.
class CommunityPhraseTakenException implements Exception {
  /// Creates a [CommunityPhraseTakenException].
  const CommunityPhraseTakenException();
}

/// Why a phrase entered to join leads to no community.
enum CommunityPhraseProblem {
  /// No community goes by the phrase in Meeting Place.
  notFound,

  /// The phrase was a community's, but it expired.
  expired,
}

/// Thrown when a phrase entered to join leads to no community.
class CommunityPhraseException implements Exception {
  /// Creates a [CommunityPhraseException] for [problem].
  const CommunityPhraseException(this.problem);

  /// Why the phrase leads to no community.
  final CommunityPhraseProblem problem;
}

/// A community's join phrase: a Meeting Place offer a member publishes, so
/// others find the community by a short phrase rather than its DID.
///
/// The offer is an unsigned pointer: its contact card carries the
/// community's DID and nothing else, none of the member's own details. Like
/// a scanned DID, it is untrusted: the community is resolved from the DID
/// and shown for review before anything is sent. Anyone may point a phrase
/// at any community, so the review, not the phrase, decides whether to
/// trust it. The offer is never accepted as a connection.
class CommunityOfferService {
  /// Creates a [CommunityOfferService] publishing through the Meeting Place
  /// SDK.
  CommunityOfferService({required this._sdk});

  final Future<MeetingPlaceCoreSDK> Function() _sdk;

  /// The contact card type of a join phrase's offer.
  static const contactCardType = 'community';

  /// The key of the community's DID in a join phrase's contact card.
  static const contactInfoKey = 'x-meetingplace-community-did';

  /// A character Meeting Place accepts in a phrase, as on the find offer
  /// screen.
  static final phraseCharacter = RegExp(r'[0-9!\-_a-zA-Z\s]');

  /// Whether [text] is made only of characters a phrase may hold.
  static bool isPhrase(String text) =>
      text.isNotEmpty && text.split('').every(phraseCharacter.hasMatch);

  /// Marks this phone's join phrase offers, with the community's DID.
  static const _externalRefPrefix = 'vtc-join-phrase:';

  /// The community DID a join phrase's [card] points to, unchecked, or null
  /// when it is no join phrase.
  static String? communityDidOf(ContactCard card) =>
      switch (card.contactInfo[contactInfoKey]) {
        final String did when did.isNotEmpty => did,
        _ => null,
      };

  /// Whether [offer] is a join phrase this phone published: a pointer to a
  /// community, not a connection, so it is kept off the connections list.
  static bool isJoinPhrase(ConnectionOffer offer) =>
      offer.externalRef?.startsWith(_externalRefPrefix) ?? false;

  /// Whether [phrase] is still free in Meeting Place.
  Future<bool> isPhraseAvailable(String phrase) async =>
      (await (await _sdk()).validateOfferPhrase(phrase.trim())).isAvailable;

  /// The DID the join phrase [phrase] points to, unchecked: the caller
  /// resolves and shows the community before trusting it. Nothing else of
  /// the offer is taken: not its name, nor its invitation.
  ///
  /// Throws [CommunityPhraseException] when the phrase leads to no
  /// community, and [MeetingPlaceCoreSDKException] when Meeting Place
  /// cannot be reached.
  Future<String> findCommunity(String phrase) async {
    final FindOfferResult result;
    try {
      result = await (await _sdk()).findOffer(mnemonic: phrase.trim());
    } on MeetingPlaceCoreSDKException catch (error) {
      if (error.code ==
          MeetingPlaceCoreSDKErrorCode.connectionOfferExpired.value) {
        throw const CommunityPhraseException(CommunityPhraseProblem.expired);
      }
      if (error.code ==
          MeetingPlaceCoreSDKErrorCode.connectionOfferNotFoundError.value) {
        throw const CommunityPhraseException(CommunityPhraseProblem.notFound);
      }
      rethrow;
    }
    // Whether this phone could claim the offer does not matter: a join
    // phrase is never claimed.
    final offer = result.connectionOffer;
    final communityDid = offer == null
        ? null
        : communityDidOf(offer.contactCard);
    if (communityDid == null) {
      throw const CommunityPhraseException(CommunityPhraseProblem.notFound);
    }
    return communityDid;
  }

  /// The join phrase this phone published for [communityDid] and has not
  /// withdrawn, or null.
  Future<ConnectionOffer?> published(String communityDid) async =>
      (await _publishedOffers())
          .where((offer) => offer.externalRef == _externalRef(communityDid))
          .firstOrNull;

  /// Publishes [phrase] as the join phrase of [communityDid], named
  /// [communityName], in place of one this phone published before. It lasts
  /// until withdrawn.
  ///
  /// Throws [CommunityPhraseTakenException] when the phrase is registered
  /// already, and [MeetingPlaceCoreSDKException] when Meeting Place cannot
  /// be reached.
  Future<ConnectionOffer> publish(
    String communityDid, {
    required String phrase,
    required String communityName,
  }) async {
    final trimmed = phrase.trim();
    final sdk = await _sdk();
    final previous = await published(communityDid);
    if (previous?.mnemonic != trimmed && !await isPhraseAvailable(trimmed)) {
      throw const CommunityPhraseTakenException();
    }
    if (previous != null) await sdk.markConnectionOfferAsDeleted(previous);

    final result = await sdk.publishOffer(
      PublishOfferRequest(
        offerName: communityName,
        type: SDKConnectionOfferType.invitation,
        contactCard: ContactCard(
          did: '',
          type: contactCardType,
          contactInfo: {contactInfoKey: communityDid},
        ),
        offerDescription: '',
        customMnemonic: trimmed,
        externalRef: _externalRef(communityDid),
      ),
    );
    return result.connectionOffer;
  }

  /// Withdraws the join phrase this phone published for [communityDid], if
  /// any.
  Future<void> withdraw(String communityDid) async {
    final offer = await published(communityDid);
    if (offer == null) return;
    await (await _sdk()).markConnectionOfferAsDeleted(offer);
  }

  Future<List<ConnectionOffer>> _publishedOffers() async => [
    for (final offer in await (await _sdk()).listConnectionOffers())
      if (offer.ownedByMe && !offer.isDeleted && isJoinPhrase(offer)) offer,
  ];

  static String _externalRef(String communityDid) =>
      '$_externalRefPrefix$communityDid';
}

/// Provides the [CommunityOfferService].
final communityOfferServiceProvider = Provider<CommunityOfferService>(
  (ref) => CommunityOfferService(
    sdk: () => ref.read(meetingPlaceSdkProvider.future),
  ),
  name: 'communityOfferServiceProvider',
);
