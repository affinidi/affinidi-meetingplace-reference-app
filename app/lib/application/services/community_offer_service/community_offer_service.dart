import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../vtc_service/vtc_service.dart';

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

  /// The phrase names a community, but no admin's statement for it
  /// verifies.
  notVouched,
}

/// Thrown when a phrase entered to join leads to no community.
class CommunityPhraseException implements Exception {
  /// Creates a [CommunityPhraseException] for [problem].
  const CommunityPhraseException(this.problem);

  /// Why the phrase leads to no community.
  final CommunityPhraseProblem problem;
}

/// A community's join phrase: a Meeting Place offer one of its admins
/// publishes, so members find the community by a short phrase rather than
/// its DID.
///
/// The offer is only a pointer. Its contact card carries nothing but the
/// admin's signed statement that the phrase leads to the community
/// ([CommunityOffer]), and the admin's own contact details never leave the
/// phone. The offer is never accepted as a connection.
class CommunityOfferService {
  /// Creates a [CommunityOfferService] publishing through the Meeting Place
  /// SDK and signing through the member's VTA.
  CommunityOfferService({required this._sdk, required this._vtc});

  final Future<MeetingPlaceCoreSDK> Function() _sdk;
  final VtcService _vtc;

  /// The contact card type of a join phrase's offer.
  static const contactCardType = 'community';

  /// A character Meeting Place accepts in a phrase, as on the find offer
  /// screen.
  static final phraseCharacter = RegExp(r'[0-9!\-_a-zA-Z\s]');

  /// Whether [text] is made only of characters a phrase may hold.
  static bool isPhrase(String text) =>
      text.isNotEmpty && text.split('').every(phraseCharacter.hasMatch);

  /// Marks this phone's join phrase offers, with the community's DID.
  static const _externalRefPrefix = 'vtc-join-phrase:';

  /// The admin's statement a join phrase's [card] carries, unverified, or
  /// null when it is no join phrase.
  static Map<String, dynamic>? statementOf(ContactCard card) =>
      switch (card.contactInfo[CommunityOffer.contactInfoKey]) {
        final Map<String, dynamic> statement => statement,
        _ => null,
      };

  /// Whether [offer] is a join phrase this phone published: a pointer to a
  /// community, not a connection, so it is kept off the connections list.
  static bool isJoinPhrase(ConnectionOffer offer) =>
      offer.externalRef?.startsWith(_externalRefPrefix) ?? false;

  /// Whether [phrase] is still free in Meeting Place.
  Future<bool> isPhraseAvailable(String phrase) async =>
      (await (await _sdk()).validateOfferPhrase(phrase.trim())).isAvailable;

  /// The DID of the community whose join phrase [phrase] is, once the
  /// admin's statement the offer carries verifies. Nothing else of the
  /// offer is taken: not its name, nor its contact card, nor its invitation.
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
    final statement = offer == null ? null : statementOf(offer.contactCard);
    if (offer == null || statement == null) {
      throw const CommunityPhraseException(CommunityPhraseProblem.notFound);
    }
    try {
      // The phrase the offer is registered under, as Meeting Place has it.
      return await CommunityOffer.verify(statement, phrase: offer.mnemonic);
    } on MeetingPlaceVtcSDKException {
      throw const CommunityPhraseException(CommunityPhraseProblem.notVouched);
    }
  }

  /// The join phrase this phone published for [communityDid] and has not
  /// withdrawn, or null.
  Future<ConnectionOffer?> published(String communityDid) async =>
      (await _publishedOffers())
          .where((offer) => offer.externalRef == _externalRef(communityDid))
          .firstOrNull;

  /// Publishes [phrase] as the join phrase of [communityDid], named
  /// [communityName], in place of one this phone published before. It lasts
  /// as long as the member's admin role card.
  ///
  /// Throws [CommunityPhraseTakenException] when the phrase is registered
  /// already, [NotCommunityAdminException] when the member is no admin of
  /// the community, and as [VtcService.vouchForPhrase] does.
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
    final statement = await _vtc.vouchForPhrase(communityDid, trimmed);
    if (previous != null) await sdk.markConnectionOfferAsDeleted(previous);

    final result = await sdk.publishOffer(
      PublishOfferRequest(
        offerName: communityName,
        type: SDKConnectionOfferType.invitation,
        contactCard: ContactCard(
          did: '',
          type: contactCardType,
          contactInfo: {CommunityOffer.contactInfoKey: statement},
        ),
        offerDescription: '',
        customMnemonic: trimmed,
        validUntil: DateTime.parse(statement['validUntil'] as String),
        externalRef: _externalRef(communityDid),
      ),
    );
    return result.connectionOffer;
  }

  /// Withdraws the join phrase this phone published for [communityDid], if
  /// any. A copy of its statement stays valid until it expires.
  Future<void> withdraw(String communityDid) async {
    final offer = await published(communityDid);
    if (offer == null) return;
    await (await _sdk()).markConnectionOfferAsDeleted(offer);
  }

  /// Publishes each of this phone's join phrases again whose admin role card
  /// the community renewed, so the phrase outlives the card it was first
  /// signed with. A phrase whose card was not renewed expires with it.
  /// Best effort: one that fails is tried again next time.
  Future<void> refresh() async {
    for (final offer in await _publishedOffers()) {
      final communityDid = offer.externalRef!.substring(
        _externalRefPrefix.length,
      );
      try {
        final card = await _vtc.adminRoleCard(communityDid);
        final signedWith = statementOf(offer.contactCard)?['roleCard'];
        final renewedUntil = card == null
            ? null
            : CommunityRoleCard.validUntil(card);
        final signedUntil = signedWith is Map<String, dynamic>
            ? CommunityRoleCard.validUntil(signedWith)
            : null;
        if (renewedUntil == null ||
            (signedUntil != null && !renewedUntil.isAfter(signedUntil))) {
          continue;
        }
        await publish(
          communityDid,
          phrase: offer.mnemonic,
          communityName: offer.offerName,
        );
      } on Exception {
        continue;
      }
    }
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
    vtc: ref.read(vtcServiceProvider),
  ),
  name: 'communityOfferServiceProvider',
);
